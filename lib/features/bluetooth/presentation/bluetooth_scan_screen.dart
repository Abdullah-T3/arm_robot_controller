import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/bluetooth_provider.dart';
import '../models/bluetooth_state.dart';

class BluetoothScanScreen extends ConsumerStatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  ConsumerState<BluetoothScanScreen> createState() =>
      _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends ConsumerState<BluetoothScanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Auto-start scanning when the screen first appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bluetoothProvider.notifier).scanIfBluetoothOn();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Device'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(bluetoothProvider.notifier).scanIfBluetoothOn(),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          // Listen for errors
          ref.listen<BluetoothState>(bluetoothProvider, (previous, next) {
            next.whenOrNull(
              error: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Connecting failed. Re-scanning...'),
                  ),
                );
                ref.read(bluetoothProvider.notifier).scanIfBluetoothOn();
              },
            );
          });

          final state = ref.watch(bluetoothProvider);

          return Stack(
            children: [
              state.when(
                initial: () =>
                    _buildScanLayout(context, isScanning: false, devices: []),
                scanning: () =>
                    _buildScanLayout(context, isScanning: true, devices: []),
                available: (devices) => _buildScanLayout(
                  context,
                  isScanning: false,
                  devices: devices,
                ),
                off: () => _buildBluetoothOffLayout(context),
                on: () =>
                    _buildScanLayout(context, isScanning: false, devices: []),
                connecting: () =>
                    _buildScanLayout(context, isScanning: false, devices: []),
                connected: (device) => _buildConnectedView(context, device),
                disconnected: () =>
                    _buildScanLayout(context, isScanning: false, devices: []),
                error: (message) =>
                    _buildScanLayout(context, isScanning: false, devices: []),
              ),
              // Loading overlay for connecting state
              if (state is BluetoothConnecting)
                _buildConnectingOverlay(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScanHeader(BuildContext context, {required bool isScanning}) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color ring = primary.withOpacity(0.15);
    final Color ring2 = primary.withOpacity(0.25);
    final Color ring3 = primary.withOpacity(0.40);

    return Center(
      child: SizedBox(
        width: 240.r,
        height: 240.r,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulsing ring
            ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                CurvedAnimation(
                  parent: _pulseController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: Container(
                width: 240.r,
                height: 240.r,
                decoration: BoxDecoration(shape: BoxShape.circle, color: ring),
              ),
            ),
            Container(
              width: 200.r,
              height: 200.r,
              decoration: BoxDecoration(shape: BoxShape.circle, color: ring2),
            ),
            Container(
              width: 160.r,
              height: 160.r,
              decoration: BoxDecoration(shape: BoxShape.circle, color: ring3),
            ),
            Container(
              width: 120.r,
              height: 120.r,
              decoration: BoxDecoration(shape: BoxShape.circle, color: primary),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bluetooth, color: Colors.white, size: 32.r),
                  SizedBox(height: 8.h),
                  Text(
                    isScanning ? 'SCANNING' : 'SCAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanLayout(
    BuildContext context, {
    required bool isScanning,
    required List<Device> devices,
  }) {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        _buildScanHeader(context, isScanning: isScanning),
        SizedBox(height: 12.h),
        Center(
          child: Text(
            'Searching for nearby devices...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Discovered Devices',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),
        if (devices.isNotEmpty)
          ...devices.asMap().entries.map((entry) {
            final index = entry.key;
            final device = entry.value;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: _deviceTile(context, device),
            );
          })
        else if (isScanning)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12.w),
                const Text('Scanning for devices...'),
              ],
            ),
          )
        else
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Column(
                children: [
                  Icon(
                    Icons.bluetooth_searching,
                    size: 48.r,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No devices found yet',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Pull down to refresh',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBluetoothOffLayout(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_disabled, size: 48.r, color: Colors.red),
            SizedBox(height: 16.h),
            const Text(
              'Bluetooth is turned off. Please enable Bluetooth to scan.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () =>
                  ref.read(bluetoothProvider.notifier).openBluetoothSettings(),
              child: const Text('Open Bluetooth Settings'),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () =>
                  ref.read(bluetoothProvider.notifier).scanIfBluetoothOn(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Deprecated by unified layout above; kept for reference
  Widget _buildScanningView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildScanHeader(context, isScanning: true),
          SizedBox(height: 16.h),
          const Text('Searching for nearby devices...'),
        ],
      ),
    );
  }

  Widget _buildBluetoothOffView(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_disabled, size: 48.r, color: Colors.red),
            SizedBox(height: 16.h),
            const Text(
              'Bluetooth is turned off. Please enable Bluetooth to scan.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () =>
                  ref.read(bluetoothProvider.notifier).openBluetoothSettings(),
              child: const Text('Open Bluetooth Settings'),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () =>
                  ref.read(bluetoothProvider.notifier).scanIfBluetoothOn(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deviceTile(BuildContext context, Device device) {
    final state = ref.watch(bluetoothProvider);
    final isConnecting = state is BluetoothConnecting;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 12.r),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isConnecting
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.memory,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name ?? 'Unknown Device',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 4.h),
                Text(
                  'ID: ${device.address}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: isConnecting
                ? null
                : () async {
                    await ref
                        .read(bluetoothProvider.notifier)
                        .connectToDevice(device);
                  },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 32.w),
            padding: EdgeInsets.all(32.r),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated loading indicator
                SizedBox(
                  width: 80.r,
                  height: 80.r,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer rotating ring
                      RotationTransition(
                        turns: _pulseController,
                        child: Container(
                          width: 80.r,
                          height: 80.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: CustomPaint(
                            painter: _ArcPainter(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      // Center icon
                      Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bluetooth_searching,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28.r,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                // Pulsing text
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Opacity(opacity: value, child: child);
                  },
                  onEnd: () {
                    // Restart animation
                  },
                  child: Text(
                    'Connecting...',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please wait while we establish connection',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedView(BuildContext context, Device device) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon with animated background
              Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.bluetooth_connected,
                  size: 60.r,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Successfully Connected!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.memory,
                      size: 20.r,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      device.name ?? 'Unknown Device',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              // Primary action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/control');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Go to Arm Controller'),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward, size: 20.r),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              // Secondary action button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      ref.read(bluetoothProvider.notifier).disconnect(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text('Disconnect'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.r, color: Colors.red),
          SizedBox(height: 16.h),
          Text('Error: $message', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// Custom painter for the arc loading indicator
class _ArcPainter extends CustomPainter {
  final Color color;

  _ArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const startAngle = -3.14159 / 2; // Start from top
    const sweepAngle = 3.14159; // Half circle

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
