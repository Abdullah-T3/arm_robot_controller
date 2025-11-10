import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../features/bluetooth/presentation/bluetooth_scan_screen.dart';
import '../../features/arm_control/presentation/arm_control_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/presets/presentation/presets_screen.dart';
import '../../features/arm_control/presentation/arm_3d_viewer_screen.dart';
import '../../core/responsive/orientation_lock.dart';
import '../splash_screen.dart';

class AppRouter {
  final GoRouter appRouter = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const OrientationLock(
          orientations: [DeviceOrientation.portraitUp],
          child: SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const OrientationLock(
          orientations: [DeviceOrientation.portraitUp],
          child: BluetoothScanScreen(),
        ),
      ),
      GoRoute(
        path: '/control',
        builder: (context, state) => const ArmControlScreen(),
      ),
      GoRoute(
        path: '/control3d',
        builder: (context, state) => const OrientationLock(
          orientations: [DeviceOrientation.portraitUp],
          child: Arm3DViewerScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const OrientationLock(
          orientations: [DeviceOrientation.portraitUp],
          child: SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/presets',
        builder: (context, state) => const OrientationLock(
          orientations: [DeviceOrientation.portraitUp],
          child: PresetsScreen(),
        ),
      ),
    ],
  );
}
