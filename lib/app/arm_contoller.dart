import 'package:arm_robot_controller/features/bluetooth/cubit/bluetooth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import '../core/theme/app_theme.dart';
import '../features/arm_control/cubit/arm_control_cubit.dart';
import 'routing/app_router.dart';

class ArmContollerApp extends StatelessWidget {
  const ArmContollerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => GetIt.I<BluetoothCubit>()),
            BlocProvider(create: (_) => GetIt.I<ArmControlCubit>()),
          ],
          child: MaterialApp.router(
            title: 'Robot Arm Controller',
            theme: AppTheme.darkTheme,
            routerConfig: AppRouter().appRouter,
          ),
        );
      },
    );
  }
}
