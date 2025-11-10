import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  late final Box _box;

  SettingsCubit() : super(SettingsState.initial()) {
    _box = Hive.box('settings');
    _load();
  }

  void _load() {
    final darkMode = _box.get('darkMode', defaultValue: true) as bool;
    final autoConnect = _box.get('autoConnect', defaultValue: false) as bool;
    final lastAddr = _box.get('lastDeviceAddress') as String?;
    final lastName = _box.get('lastDeviceName') as String?;
    emit(SettingsState(
      darkMode: darkMode,
      autoConnect: autoConnect,
      lastDeviceAddress: lastAddr,
      lastDeviceName: lastName,
    ));
  }

  void setDarkMode(bool value) {
    _box.put('darkMode', value);
    emit(state.copyWith(darkMode: value));
  }

  void setAutoConnect(bool value) {
    _box.put('autoConnect', value);
    emit(state.copyWith(autoConnect: value));
  }

  void setLastDevice({required String address, String? name}) {
    _box.put('lastDeviceAddress', address);
    if (name != null) {
      _box.put('lastDeviceName', name);
    }
    emit(state.copyWith(lastDeviceAddress: address, lastDeviceName: name ?? state.lastDeviceName));
  }
}