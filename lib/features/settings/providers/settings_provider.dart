import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/settings_state.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  late final Box _box;

  @override
  SettingsState build() {
    _box = Hive.box('settings');
    return _loadSettings();
  }

  SettingsState _loadSettings() {
    final darkMode = _box.get('darkMode', defaultValue: true) as bool;
    final autoConnect = _box.get('autoConnect', defaultValue: false) as bool;
    final lastAddr = _box.get('lastDeviceAddress') as String?;
    final lastName = _box.get('lastDeviceName') as String?;

    return SettingsState(
      darkMode: darkMode,
      autoConnect: autoConnect,
      lastDeviceAddress: lastAddr,
      lastDeviceName: lastName,
    );
  }

  Future<void> setDarkMode(bool value) async {
    state = state.copyWith(isLoading: true);
    try {
      await _box.put('darkMode', value);
      state = state.copyWith(darkMode: value, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setAutoConnect(bool value) async {
    state = state.copyWith(isLoading: true);
    try {
      await _box.put('autoConnect', value);
      state = state.copyWith(autoConnect: value, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setLastDevice({required String address, String? name}) async {
    state = state.copyWith(isLoading: true);
    try {
      await _box.put('lastDeviceAddress', address);
      if (name != null) {
        await _box.put('lastDeviceName', name);
      }
      state = state.copyWith(
        lastDeviceAddress: address,
        lastDeviceName: name ?? state.lastDeviceName,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
