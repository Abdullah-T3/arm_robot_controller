import 'package:arm_robot_controller/app/routing/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import '../features/bluetooth/data/bluetooth_repository.dart';
import '../features/bluetooth/cubit/bluetooth_cubit.dart';
import '../features/arm_control/cubit/arm_control_cubit.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/cubit/settings_cubit.dart';
import '../features/settings/cubit/settings_state.dart';

class ArmControllerApp extends StatelessWidget {
  const ArmControllerApp({super.key});

  // Keep a single router instance to avoid resetting to initialLocation
  // when the widget tree rebuilds (e.g., on orientation changes).
  static final GoRouter _router = AppRouter().appRouter;
  static bool _autoConnectAttempted = false;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => BluetoothCubit(GetIt.I<BluetoothClassic>()),
            ),
            BlocProvider(
              create: (_) => ArmControlCubit(GetIt.I<BluetoothRepository>()),
            ),
            BlocProvider(
              create: (_) => SettingsCubit(),
            ),
          ],
          child: BlocListener<BluetoothCubit, BluetoothState>(
            listener: (context, state) {
              if (state is BluetoothDisconnected) {
                ArmControllerApp._router.go('/scan');
              }
            },
            child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settings) {
                // Attempt auto-connect once on startup if enabled
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (!_autoConnectAttempted && settings.autoConnect && settings.lastDeviceAddress != null) {
                    final bluetoothCubit = context.read<BluetoothCubit>();
                    if (bluetoothCubit.state is! BluetoothConnected) {
                      try {
                        await bluetoothCubit.connectToLastSavedDevice();
                      } catch (_) {}
                    }
                    _autoConnectAttempted = true;
                  }
                });

                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Robot Arm Controller',
                  theme: settings.darkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
                  routerConfig: _router,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
