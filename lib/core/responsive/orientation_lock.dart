import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class OrientationLock extends StatefulWidget {
  final List<DeviceOrientation> orientations;
  final Widget child;

  const OrientationLock({super.key, required this.orientations, required this.child});

  @override
  State<OrientationLock> createState() => _OrientationLockState();
}

class _OrientationLockState extends State<OrientationLock> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(widget.orientations);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}