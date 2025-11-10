import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool darkMode;
  final bool autoConnect;
  final String? lastDeviceAddress;
  final String? lastDeviceName;

  const SettingsState({
    required this.darkMode,
    required this.autoConnect,
    this.lastDeviceAddress,
    this.lastDeviceName,
  });

  factory SettingsState.initial() => const SettingsState(
        darkMode: true,
        autoConnect: false,
        lastDeviceAddress: null,
        lastDeviceName: null,
      );

  SettingsState copyWith({
    bool? darkMode,
    bool? autoConnect,
    String? lastDeviceAddress,
    String? lastDeviceName,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      autoConnect: autoConnect ?? this.autoConnect,
      lastDeviceAddress: lastDeviceAddress ?? this.lastDeviceAddress,
      lastDeviceName: lastDeviceName ?? this.lastDeviceName,
    );
  }

  @override
  List<Object?> get props => [darkMode, autoConnect, lastDeviceAddress, lastDeviceName];
}