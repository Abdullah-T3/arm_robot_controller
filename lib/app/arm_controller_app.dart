import 'package:arm_robot_controller/app/routing/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/providers/settings_provider.dart';
import '../features/bluetooth/providers/bluetooth_provider.dart';
import '../features/bluetooth/models/bluetooth_state.dart';

class ArmControllerApp extends ConsumerStatefulWidget {
  const ArmControllerApp({super.key});

  @override
  ConsumerState<ArmControllerApp> createState() => _ArmControllerAppState();
}

class _ArmControllerAppState extends ConsumerState<ArmControllerApp> {
  // Keep a single router instance to avoid resetting to initialLocation
  // when the widget tree rebuilds (e.g., on orientation changes).
  static final GoRouter _router = AppRouter().appRouter;
  static bool _autoConnectAttempted = false;

  @override
  Widget build(BuildContext context) {
    // Listen to Bluetooth state changes
    ref.listen<BluetoothState>(bluetoothProvider, (previous, next) {
      next.whenOrNull(
        disconnected: () {
          _router.go('/scan');
        },
      );
    });

    // Watch settings state
    final settings = ref.watch(settingsProvider);

    // Attempt auto-connect once on startup if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_autoConnectAttempted &&
          settings.autoConnect &&
          settings.lastDeviceAddress != null) {
        final bluetoothNotifier = ref.read(bluetoothProvider.notifier);
        final bluetoothState = ref.read(bluetoothProvider);

        bluetoothState.whenOrNull(
              connected: (_) {
                // Already connected, do nothing
              },
            ) ??
            await bluetoothNotifier.connectToLastSavedDevice();

        _autoConnectAttempted = true;
      }
    });

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Robot Arm Controller',
          theme: settings.darkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
          routerConfig: _router,
        );
      },
    );
  }
}
