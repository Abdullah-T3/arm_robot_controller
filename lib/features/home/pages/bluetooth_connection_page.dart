import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothConnectionPage extends StatefulWidget {
  const BluetoothConnectionPage({Key? key}) : super(key: key);

  @override
  State<BluetoothConnectionPage> createState() =>
      _BluetoothConnectionPageState();
}

class _BluetoothConnectionPageState extends State<BluetoothConnectionPage> {
  final BluetoothClassic _bluetooth = BluetoothClassic();
  List<Device> devices = [];
  Device? connectedDevice;
  bool isConnecting = false;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
    await Permission.location.request();
  }

  Future<void> scanForDevices() async {
    setState(() => devices.clear());
    try {
      final foundDevices = await _bluetooth.getPairedDevices();
      setState(() {
        devices = foundDevices;
      });
    } catch (e) {
      debugPrint('Error scanning for devices: $e');
    }
  }

  Future<void> connectToDevice(Device device) async {
    if (isConnecting) return;

    try {
      // Disconnect any existing connection first
      if (isConnected) {
        await _bluetooth.disconnect();
        setState(() {
          isConnected = false;
          connectedDevice = null;
        });
        // Add a small delay after disconnecting
        await Future.delayed(const Duration(milliseconds: 500));
      }

      setState(() => isConnecting = true);

      // Use the standard SPP UUID for HC-05 modules
      const String SPP_UUID = "00001101-0000-1000-8000-00805f9b34fb";

      // Set a timeout for the connection attempt
      bool connected = false;
      try {
        await Future.any([
          _bluetooth
              .connect(device.address, SPP_UUID)
              .then((_) => connected = true),
          Future.delayed(const Duration(seconds: 10)),
        ]);
      } catch (e) {
        print('Connection attempt error: $e');
      }

      if (!connected) {
        throw TimeoutException('Connection timed out after 10 seconds');
      }

      setState(() {
        connectedDevice = device;
        isConnecting = false;
        isConnected = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${device.name ?? "device"}')),
      );
    } catch (e) {
      print('Connection error: $e');
      setState(() {
        isConnecting = false;
        isConnected = false;
        connectedDevice = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> sendData(String data) async {
    if (!isConnected) return;
    try {
      await _bluetooth.write(data);
    } catch (e) {
      debugPrint('Error sending data: $e');
      setState(() {
        isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Connection')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: scanForDevices,
            child: const Text('Scan for Devices'),
          ),
          if (isConnecting)
            const CircularProgressIndicator()
          else if (devices.isEmpty)
            const Text('No devices found')
          else
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  final bool isConnected = device == connectedDevice;
                  return ListTile(
                    title: Text(device.name ?? 'Unknown Device'),
                    subtitle: Text(device.address),
                    trailing: device == connectedDevice && isConnected
                        ? const Icon(Icons.bluetooth_connected)
                        : const Icon(Icons.bluetooth),
                    onTap: (device == connectedDevice && isConnected)
                        ? null
                        : () => connectToDevice(device),
                  );
                },
              ),
            ),
          if (isConnected && connectedDevice != null) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Connected to: ${connectedDevice!.name ?? "Unknown Device"}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => sendData('1'),
                          child: const Text('Send 1'),
                        ),
                        ElevatedButton(
                          onPressed: () => sendData('0'),
                          child: const Text('Send 0'),
                        ),
                        ElevatedButton(
                          onPressed: disconnect,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Disconnect'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> disconnect() async {
    try {
      await _bluetooth.disconnect();
      setState(() {
        isConnected = false;
        connectedDevice = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnected successfully')),
      );
    } catch (e) {
      print('Disconnect error: $e');
      // Force the state to disconnected even if the disconnect call failed
      setState(() {
        isConnected = false;
        connectedDevice = null;
      });
    }
  }

  @override
  void dispose() {
    // Try to disconnect gracefully, but don't await it
    if (isConnected) {
      _bluetooth.disconnect().catchError((e) {
        print('Error disconnecting: $e');
        return false;
      });
    }
    super.dispose();
  }
}
