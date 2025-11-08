import 'dart:typed_data';

import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';

abstract class BluetoothRepository {
  Future<List<Device>> getPairedDevices();
  Future<void> connect(Device device);
  Future<void> disconnect();
  Future<void> sendData(List<int> data);
  Stream<List<int>> get dataStream;
  Future<int> checkBluetoothState();
}

class BluetoothRepositoryImpl implements BluetoothRepository {
  final BluetoothClassic _bluetooth;

  BluetoothRepositoryImpl(this._bluetooth);

  @override
  Future<List<Device>> getPairedDevices() async {
    return await _bluetooth.getPairedDevices();
  }

  @override
  Future<void> connect(Device device) async {
    // Use standard Serial Port Profile (SPP) UUID for classic modules (e.g., HC-05)
    const String sppUuid = "00001101-0000-1000-8000-00805f9b34fb";
    await _bluetooth.connect(device.address, sppUuid);
  }

  @override
  Future<void> disconnect() async {
    await _bluetooth.disconnect();
  }

  @override
  Future<void> sendData(List<int> data) async {
    final bytes = Uint8List.fromList(data);
    await _bluetooth.writeBytes(bytes); // <-- correct for bluetooth_classic
  }

  @override
  Stream<List<int>> get dataStream =>
      _bluetooth.onDeviceDataReceived().map((data) => data.toList());

  @override
  Future<int> checkBluetoothState() async {
    late int state;
    _bluetooth.onDeviceStatusChanged().listen((event) {
      if (event == 1) {
        state = 1;
        print('Bluetooth is connected');
      } else {
        state = 0;
        print('Bluetooth is disconnected');
      }
    });
    return state;
  }
}
