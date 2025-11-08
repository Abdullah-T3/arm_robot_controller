// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:arm_robot_controller/app/di/app_module.dart' as _i204;
import 'package:arm_robot_controller/features/arm_control/cubit/arm_control_cubit.dart'
    as _i217;
import 'package:arm_robot_controller/features/bluetooth/cubit/bluetooth_cubit.dart'
    as _i907;
import 'package:arm_robot_controller/features/bluetooth/data/bluetooth_repository.dart'
    as _i652;
import 'package:bluetooth_classic/bluetooth_classic.dart' as _i435;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.singleton<_i435.BluetoothClassic>(() => appModule.bluetoothClassic);
    gh.singleton<_i652.BluetoothRepository>(
      () => appModule.bluetoothRepository,
    );
    gh.factory<_i217.ArmControlCubit>(
      () => _i217.ArmControlCubit(gh<_i652.BluetoothRepository>()),
    );
    gh.factory<_i907.BluetoothCubit>(
      () => _i907.BluetoothCubit(gh<_i435.BluetoothClassic>()),
    );
    return this;
  }
}

class _$AppModule extends _i204.AppModule {}
