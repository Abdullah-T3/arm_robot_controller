import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedArmVisualizer extends StatefulWidget {
  const AnimatedArmVisualizer({
    super.key,
    required this.angles,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeInOut,
  });

  /// Angles list: [base, shoulder, elbow, wrist, gripper]
  final List<double> angles;
  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedArmVisualizer> createState() => _AnimatedArmVisualizerState();
}

class _AnimatedArmVisualizerState extends State<AnimatedArmVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  late List<double> _from;
  late List<double> _to;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _controller, curve: widget.curve);
    _from = List.from(widget.angles);
    _to = List.from(widget.angles);
  }

  @override
  void didUpdateWidget(covariant AnimatedArmVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_listEquals(oldWidget.angles, widget.angles)) {
      _from = List.from(_currentAngles);
      _to = List.from(widget.angles);
      _controller
        ..reset()
        ..forward();
    }
  }

  List<double> get _currentAngles {
    final t = _anim.value;
    return List.generate(_from.length, (i) => _lerp(_from[i], _to[i], t));
  }

  @override
  Widget build(BuildContext context) {
    // Use a high-contrast palette for better visibility
    const Color highContrastArm = Color(0xFF64B5F6); // Light Blue 300
    const Color highContrastJoint = Color(0xFFFFD166); // Warm Amber
    final Color baseSurface = Theme.of(context).colorScheme.surface;
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return CustomPaint(
          painter: _ArmPainter(
            angles: _currentAngles,
            armColor: highContrastArm,
            jointColor: highContrastJoint,
            baseColor: baseSurface,
          ),
          isComplex: true,
          willChange: true,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static bool _listEquals(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _ArmPainter extends CustomPainter {
  _ArmPainter({
    required this.angles,
    required this.armColor,
    required this.jointColor,
    required this.baseColor,
  });

  final List<double> angles; // [base, shoulder, elbow, wrist, gripper]
  final Color armColor;
  final Color jointColor;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Screen origin (base position on canvas)
    final origin = Offset(w * 0.5, h * 0.82);

    // Segment lengths as proportions of viewport (in pixel units)
    final l1 = h * 0.22; // base to shoulder (vertical column)
    final l2 = h * 0.20; // shoulder to elbow
    final l3 = h * 0.16; // elbow to wrist
    final gr = h * 0.10; // gripper length (taller)

    // Map degrees to radians; center around neutral pose
    double deg(double d) => d * math.pi / 180.0;
    final yaw = deg(angles[0] - 90); // Base yaw (horizontal rotation)
    final shPitch = deg(angles[1] - 90); // Shoulder pitch
    final elPitch = deg(angles[2] - 90); // Elbow pitch
    final wrPitch = deg(angles[3] - 90); // Wrist pitch
    final thGrip = deg(angles[4]);

    // Helper: 3D direction from yaw (around Y) and pitch (from horizontal)
    // Using spherical coords: pitch = 0 is horizontal, +90° is up
    Offset3 _dir(double yawRad, double pitchRad) {
      final cx = math.cos(pitchRad);
      final sx = math.sin(pitchRad);
      final sy = math.sin(yawRad);
      final cy = math.cos(yawRad);
      return Offset3(cx * sy, sx, cx * cy);
    }

    // Simple 3D to 2D projection with slight perspective
    // x affects horizontal heavily, z adds parallax; y is vertical up
    Offset _proj(Offset3 p) {
      const double sx = 1.0; // x scale
      const double szx = 0.55; // z contribution to x (parallax)
      const double sy = 1.0; // y scale
      const double szy = 0.18; // z contribution to y (slight perspective drop)
      final px = origin.dx + p.x * sx + p.z * szx;
      final py = origin.dy - (p.y * sy) + (p.z * szy);
      return Offset(px, py);
    }

    // Forward kinematics in 3D
    final o3 = Offset3(0, 0, 0);
    final p1_3 = o3 + Offset3(0, l1, 0);
    final d2 = _dir(yaw, shPitch);
    final p2_3 = p1_3 + d2 * l2;
    final d3 = _dir(yaw, shPitch + elPitch);
    final p3_3 = p2_3 + d3 * l3;
    final d4 = _dir(yaw, shPitch + elPitch + wrPitch);
    final p4_3 = p3_3 + d4 * gr;

    // Project to 2D canvas space
    final p1 = _proj(p1_3);
    final p2 = _proj(p2_3);
    final p3 = _proj(p3_3);
    final p4 = _proj(p4_3);
    final pGripDir2D = Offset(
      (_proj(p3_3 + d4 * 10).dx - _proj(p3_3).dx),
      (_proj(p3_3 + d4 * 10).dy - _proj(p3_3).dy),
    ).normalize();

    // Paints
    final armPaint = Paint()
      ..color = armColor
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final armInnerPaint = Paint()
      ..color = armColor
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = armColor.withOpacity(0.20)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final jointPaint = Paint()..color = jointColor;
    final basePaint = Paint()..color = baseColor;
    final gripPaint = Paint()
      ..color = armColor
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Subtle grid background to match the sketch
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    final stepX = w / 12;
    final stepY = h / 12;
    for (double x = stepX; x < w; x += stepX) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = stepY; y < h; y += stepY) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Rounded base like the photo
    final baseRect = Rect.fromCenter(
      center: origin + const Offset(0, 10),
      width: w * 0.52,
      height: h * 0.12,
    );
    final baseRRect = RRect.fromRectAndRadius(
      baseRect,
      Radius.circular(h * 0.04),
    );
    canvas.drawRRect(baseRRect, basePaint);
    final baseCircleRadius = 12.0;
    final baseCircleCenter = baseRect.center;
    canvas.drawCircle(baseCircleCenter, baseCircleRadius, jointPaint);

    // Slanted lines to the right and left of the bottom circle
    final leftAnchor = baseCircleCenter + Offset(-(baseCircleRadius + 2), 0);
    final rightAnchor = baseCircleCenter + Offset((baseCircleRadius + 2), 0);
    final leftEnd = Offset(baseRect.left + 24, baseRect.bottom - 12);
    final rightEnd = Offset(baseRect.right - 24, baseRect.bottom - 12);
    canvas.drawLine(leftAnchor, leftEnd, shadowPaint);
    canvas.drawLine(rightAnchor, rightEnd, shadowPaint);
    canvas.drawLine(leftAnchor, leftEnd, armPaint);
    canvas.drawLine(rightAnchor, rightEnd, armPaint);

    // Helper to draw double-line segment with shadow
    void drawSegment(Offset a, Offset b) {
      final d = b - a;
      final n = Offset(-d.dy, d.dx).normalize();
      final o = n * 4;
      canvas.drawLine(a, b, shadowPaint);
      canvas.drawLine(a + o, b + o, armPaint);
      canvas.drawLine(a - o, b - o, armInnerPaint);
    }

    // Segments
    drawSegment(origin, p1);
    drawSegment(p1, p2);
    drawSegment(p2, p3);
    drawSegment(p3, p4);

    // Joints
    canvas.drawCircle(p1, 10, jointPaint);
    canvas.drawCircle(p2, 9, jointPaint);
    canvas.drawCircle(p3, 9, jointPaint);

    // Gripper in a Y-like shape
    final gripAngle = thGrip.clamp(0, deg(90));
    final gripLen = gr * 0.9; // longer fingers for taller look
    final ortho = Offset(-pGripDir2D.dy, pGripDir2D.dx);
    final spread = math.sin(gripAngle) * (h * 0.065); // much wider spread
    final fingerA = p4 + (pGripDir2D * gripLen) + (ortho * spread);
    final fingerB = p4 + (pGripDir2D * gripLen) - (ortho * spread);
    canvas.drawLine(p4, fingerA, gripPaint);
    canvas.drawLine(p4, fingerB, gripPaint);
  }

  @override
  bool shouldRepaint(covariant _ArmPainter oldDelegate) {
    if (oldDelegate.angles.length != angles.length) return true;
    for (var i = 0; i < angles.length; i++) {
      if (oldDelegate.angles[i] != angles[i]) return true;
    }
    return false;
  }
}

// Simple 3D vector helper for FK math
class Offset3 {
  final double x;
  final double y;
  final double z;
  const Offset3(this.x, this.y, this.z);

  Offset3 operator +(Offset3 other) =>
      Offset3(x + other.x, y + other.y, z + other.z);
  Offset3 operator *(double s) => Offset3(x * s, y * s, z * s);
}

extension _OffsetNorm on Offset {
  Offset normalize() {
    final d = distance;
    if (d == 0) return this;
    return Offset(dx / d, dy / d);
  }
}
