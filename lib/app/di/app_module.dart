import 'package:injectable/injectable.dart';
import '../../features/bluetooth/data/bluetooth_repository.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';

@module
abstract class AppModule {
  @singleton
  BluetoothClassic get bluetoothClassic => BluetoothClassic();

  @singleton
  BluetoothRepository get bluetoothRepository =>
      BluetoothRepositoryImpl(bluetoothClassic);

  // Repository registrations only
}
