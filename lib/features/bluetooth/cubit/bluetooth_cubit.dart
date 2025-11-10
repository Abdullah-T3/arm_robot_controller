import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart' as bluetooth;
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'bluetooth_state.dart';

@injectable
class BluetoothCubit extends Cubit<BluetoothState> {
  final BluetoothClassic _bluetooth;
  bool _connectingInProgress = false;

  BluetoothCubit(this._bluetooth) : super(BluetoothInitial());

  Future<void> startScanning() async {
    emit(BluetoothScanning());
    try {
      final devices = await _bluetooth.getPairedDevices();
      emit(BluetoothAvailable(devices));
    } catch (e) {
      emit(BluetoothError(e.toString()));
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

      emit(BluetoothScanning());

      // If Bluetooth is off or unavailable, many plugins throw on this call.
      final devices = await _bluetooth.getPairedDevices();
      emit(BluetoothAvailable(devices));
    } catch (e) {
      // Treat any failure here as Bluetooth unavailable/off for UX simplicity.
      emit(BluetoothOff());
    }
  }

  Future<void> connectToDevice(bluetooth.Device device) async {
    if (_connectingInProgress) return;
    _connectingInProgress = true;
    emit(const BluetoothConnecting());
    try {
      // Ensure runtime permissions (Android 12+ requires BLUETOOTH_CONNECT)
      try {
        await _bluetooth.initPermissions();
      } catch (_) {}
      if (Platform.isAndroid) {
        final status = await Permission.bluetoothConnect.request();
        if (!status.isGranted) {
          emit(const BluetoothError('Bluetooth Connect permission denied'));
          return;
        }
      }

      // If already connected, disconnect first and give the adapter a short breather
      if (state is BluetoothConnected) {
        try {
          await _bluetooth.disconnect();
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 500));
      }

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

      emit(BluetoothConnected(device));
    } on TimeoutException {
      // Try to clean up any half-open socket and report a user-friendly error
      try {
        await _bluetooth.disconnect();
      } catch (_) {}
      emit(const BluetoothError('Connection timed out. Please try again.'));
    } catch (e) {
      emit(BluetoothError(e.toString()));
    } finally {
      _connectingInProgress = false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _bluetooth.disconnect();
      emit(const BluetoothDisconnected());
    } catch (e) {
      emit(BluetoothError(e.toString()));
    }
  }

  Future<void> getBluetoothState() async {
    try {
      final state = await _bluetooth.onDeviceStatusChanged();
      if (state == 0) {
        emit(BluetoothOff());
      }
      emit(BluetoothOn());
    } catch (e) {
      emit(BluetoothError(e.toString()));
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
      emit(BluetoothError(e.toString()));
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
      bluetooth.Device? match;
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
