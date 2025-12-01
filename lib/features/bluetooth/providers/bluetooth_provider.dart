import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/bluetooth_state.dart';

part 'bluetooth_provider.g.dart';

// Provider for BluetoothClassic instance
@riverpod
BluetoothClassic bluetoothClassic(Ref ref) {
  return BluetoothClassic();
}

@riverpod
class Bluetooth extends _$Bluetooth {
  bool _connectingInProgress = false;

  @override
  BluetoothState build() {
    return const BluetoothInitial();
  }

  BluetoothClassic get _bluetooth => ref.read(bluetoothClassicProvider);

  Future<void> startScanning() async {
    state = const BluetoothScanning();
    try {
      final devices = await _bluetooth.getPairedDevices();
      state = BluetoothAvailable(devices);
    } catch (e) {
      state = BluetoothError(e.toString());
    }
  }

  /// Checks if Bluetooth is on (and permissions are granted) before scanning.
  /// If Bluetooth appears to be off or unavailable, emits [BluetoothOff].
  /// Otherwise proceeds to fetch paired devices.
  Future<void> scanIfBluetoothOn() async {
    try {
      // Attempt to initialize permissions if available; ignore errors here.
      try {
        await _bluetooth.initPermissions();
      } catch (_) {}

      state = const BluetoothScanning();

      // If Bluetooth is off or unavailable, many plugins throw on this call.
      final devices = await _bluetooth.getPairedDevices();
      state = BluetoothAvailable(devices);
    } catch (e) {
      // Treat any failure here as Bluetooth unavailable/off for UX simplicity.
      state = const BluetoothOff();
    }
  }

  Future<void> connectToDevice(Device device) async {
    if (_connectingInProgress) return;
    _connectingInProgress = true;
    state = const BluetoothConnecting();
    try {
      // Ensure runtime permissions (Android 12+ requires BLUETOOTH_CONNECT)
      try {
        await _bluetooth.initPermissions();
      } catch (_) {}
      if (Platform.isAndroid) {
        final status = await Permission.bluetoothConnect.request();
        if (!status.isGranted) {
          state = const BluetoothError('Bluetooth Connect permission denied');
          return;
        }
      }

      // If already connected, disconnect first and give the adapter a short breather
      state.whenOrNull(
        connected: (_) async {
          try {
            await _bluetooth.disconnect();
          } catch (_) {}
          await Future.delayed(const Duration(milliseconds: 500));
        },
      );

      const sppUuid = "00001101-0000-1000-8000-00805f9b34fb";

      // Add a timeout so the UI does not hang forever on flaky connections
      await _bluetooth
          .connect(device.address, sppUuid)
          .timeout(const Duration(seconds: 10));

      // Persist last connected device for auto-connect
      try {
        final box = Hive.box('settings');
        box.put('lastDeviceAddress', device.address);
        box.put('lastDeviceName', device.name);
      } catch (_) {}

      state = BluetoothConnected(device);
    } on TimeoutException {
      // Try to clean up any half-open socket and report a user-friendly error
      try {
        await _bluetooth.disconnect();
      } catch (_) {}
      state = const BluetoothError('Connection timed out. Please try again.');
    } catch (e) {
      state = BluetoothError(e.toString());
    } finally {
      _connectingInProgress = false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _bluetooth.disconnect();
      state = const BluetoothDisconnected();
    } catch (e) {
      state = BluetoothError(e.toString());
    }
  }

  Future<void> getBluetoothState() async {
    try {
      final btState = await _bluetooth.onDeviceStatusChanged();
      if (btState == 0) {
        state = const BluetoothOff();
      } else {
        state = const BluetoothOn();
      }
    } catch (e) {
      state = BluetoothError(e.toString());
    }
  }

  Future<void> openBluetoothSettings() async {
    try {
      if (Platform.isAndroid) {
        try {
          const intent = AndroidIntent(
            action: 'android.settings.BLUETOOTH_SETTINGS',
          );
          await intent.launch();
        } catch (_) {
          // Fallback if plugin not registered or fails: open app settings.
          await openAppSettings();
        }
      } else if (Platform.isIOS) {
        await openAppSettings();
      }
    } catch (e) {
      state = BluetoothError(e.toString());
    }
  }

  /// Attempts to auto-connect to the last saved device (if present in paired devices).
  Future<void> connectToLastSavedDevice() async {
    if (_connectingInProgress) return;
    try {
      final box = Hive.box('settings');
      final address = box.get('lastDeviceAddress') as String?;
      if (address == null) return;

      // Ensure permissions and discover paired devices
      try {
        await _bluetooth.initPermissions();
      } catch (_) {}

      final devices = await _bluetooth.getPairedDevices();
      Device? match;
      for (final d in devices) {
        if (d.address == address) {
          match = d;
          break;
        }
      }

      if (match != null) {
        await connectToDevice(match);
      }
    } catch (_) {
      // Swallow errors to avoid blocking app startup
    }
  }
}
