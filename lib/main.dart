import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/arm_controller_app.dart';
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
  await Hive.initFlutter();
  await Hive.openBox('presets');
  await Hive.openBox('settings');

  runApp(const ProviderScope(child: ArmControllerApp()));
}
