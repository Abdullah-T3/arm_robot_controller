import 'package:bluetooth_classic/models/device.dart';

sealed class BluetoothState {
  const BluetoothState();

  T when<T>({
    required T Function() initial,
    required T Function() scanning,
    required T Function(List<Device> devices) available,
    required T Function() off,
    required T Function() on,
    required T Function() connecting,
    required T Function(Device device) connected,
    required T Function() disconnected,
    required T Function(String message) error,
  }) {
    final state = this;
    if (state is BluetoothInitial) return initial();
    if (state is BluetoothScanning) return scanning();
    if (state is BluetoothAvailable) return available(state.devices);
    if (state is BluetoothOff) return off();
    if (state is BluetoothOn) return on();
    if (state is BluetoothConnecting) return connecting();
    if (state is BluetoothConnected) return connected(state.device);
    if (state is BluetoothDisconnected) return disconnected();
    if (state is BluetoothError) return error(state.message);
    throw Exception('Unknown BluetoothState: $state');
  }

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? scanning,
    T Function(List<Device> devices)? available,
    T Function()? off,
    T Function()? on,
    T Function()? connecting,
    T Function(Device device)? connected,
    T Function()? disconnected,
    T Function(String message)? error,
  }) {
    final state = this;
    if (state is BluetoothInitial && initial != null) return initial();
    if (state is BluetoothScanning && scanning != null) return scanning();
    if (state is BluetoothAvailable && available != null) {
      return available(state.devices);
    }
    if (state is BluetoothOff && off != null) return off();
    if (state is BluetoothOn && on != null) return on();
    if (state is BluetoothConnecting && connecting != null) return connecting();
    if (state is BluetoothConnected && connected != null) {
      return connected(state.device);
    }
    if (state is BluetoothDisconnected && disconnected != null) {
      return disconnected();
    }
    if (state is BluetoothError && error != null) return error(state.message);
    return null;
  }
}

class BluetoothInitial extends BluetoothState {
  const BluetoothInitial();
}

class BluetoothScanning extends BluetoothState {
  const BluetoothScanning();
}

class BluetoothAvailable extends BluetoothState {
  final List<Device> devices;
  const BluetoothAvailable(this.devices);
}

class BluetoothOff extends BluetoothState {
  const BluetoothOff();
}

class BluetoothOn extends BluetoothState {
  const BluetoothOn();
}

class BluetoothConnecting extends BluetoothState {
  const BluetoothConnecting();
}

class BluetoothConnected extends BluetoothState {
  final Device device;
  const BluetoothConnected(this.device);
}

class BluetoothDisconnected extends BluetoothState {
  const BluetoothDisconnected();
}

class BluetoothError extends BluetoothState {
  final String message;
  const BluetoothError(this.message);
}
