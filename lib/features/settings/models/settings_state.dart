class SettingsState {
  final bool darkMode;
  final bool autoConnect;
  final String? lastDeviceAddress;
  final String? lastDeviceName;
  final bool isLoading;
  final String? error;

  const SettingsState({
    this.darkMode = true,
    this.autoConnect = false,
    this.lastDeviceAddress,
    this.lastDeviceName,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    bool? darkMode,
    bool? autoConnect,
    String? lastDeviceAddress,
    String? lastDeviceName,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      autoConnect: autoConnect ?? this.autoConnect,
      lastDeviceAddress: lastDeviceAddress ?? this.lastDeviceAddress,
      lastDeviceName: lastDeviceName ?? this.lastDeviceName,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
