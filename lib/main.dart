import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/di/injection.dart';
import 'app/arm_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock the app to portrait by default
  await SystemChrome.setPreferredOrientations(
    const [DeviceOrientation.portraitUp],
  );
  await Hive.initFlutter();
  // Open a box for presets storage
  await Hive.openBox('presets');
  configureDependencies();
  runApp(const ArmControllerApp());
}
