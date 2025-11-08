part of 'bluetooth_cubit.dart';

sealed class BluetoothState extends Equatable {
  const BluetoothState();

  @override
  List<Object> get props => [];
}

final class BluetoothInitial extends BluetoothState {}

final class BluetoothScanning extends BluetoothState {}

final class BluetoothAvailable extends BluetoothState {
  final List<bluetooth.Device> devices;
  const BluetoothAvailable(this.devices);
}

final class BluetoothOff extends BluetoothState {}

final class BluetoothOn extends BluetoothState {}

class BluetoothConnecting extends BluetoothState {
  const BluetoothConnecting();
}

class BluetoothConnected extends BluetoothState {
  final bluetooth.Device device;
  const BluetoothConnected(this.device);
}

class BluetoothDisconnected extends BluetoothState {
  const BluetoothDisconnected();
}

class BluetoothError extends BluetoothState {
  final String message;
  const BluetoothError(this.message);
}
