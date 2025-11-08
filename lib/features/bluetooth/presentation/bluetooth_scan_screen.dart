import 'package:arm_robot_controller/features/bluetooth/cubit/bluetooth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BluetoothScanScreen extends StatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  State<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();

    // Auto-start scanning when the screen first appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BluetoothCubit>().scanIfBluetoothOn();
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
                context.read<BluetoothCubit>().scanIfBluetoothOn(),
          ),
        ],
      ),
      body: BlocConsumer<BluetoothCubit, BluetoothState>(
        listener: (context, state) {
          if (state is BluetoothError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Connecting failed. Re-scanning...')),
            );
            context.read<BluetoothCubit>().scanIfBluetoothOn();
          }
        },
        builder: (context, state) {
          if (state is BluetoothConnected) {
            return _buildConnectedView(context, state.device);
          }

          // Build unified scan layout with animated ripple header
          return ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              _buildScanHeader(context,
                  isScanning: state is BluetoothScanning ||
                      state is BluetoothAvailable ||
                      state is BluetoothError ||
                      state is BluetoothInitial ||
                      state is BluetoothDisconnected),
              SizedBox(height: 12.h),
              Center(
                child: Text(
                  'Searching for nearby devices...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: 24.h),
              if (state is BluetoothOff) _buildBluetoothOffView(context) else ...[
                Text(
                  'Discovered Devices',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12.h),
                if (state is BluetoothAvailable)
                  ...state.devices.map((d) => _deviceTile(context, d))
                else if (state is BluetoothScanning)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: const Text('Scanning...'),
                    ),
                  )
                else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: const Text('No devices found yet'),
                    ),
                  ),
              ],
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
              scale: Tween<double>(begin: 0.95, end: 1.05)
                  .animate(CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              )),
              child: Container(
                width: 240.r,
                height: 240.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ring,
                ),
              ),
            ),
            Container(
              width: 200.r,
              height: 200.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ring2,
              ),
            ),
            Container(
              width: 160.r,
              height: 160.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ring3,
              ),
            ),
            Container(
              width: 120.r,
              height: 120.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary,
              ),
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
                  context.read<BluetoothCubit>().openBluetoothSettings(),
              child: const Text('Open Bluetooth Settings'),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () =>
                  context.read<BluetoothCubit>().scanIfBluetoothOn(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deviceTile(BuildContext context, Device device) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.r),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12.r),
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
            child:
                Icon(Icons.memory, color: Theme.of(context).colorScheme.primary),
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
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: () async {
              await context.read<BluetoothCubit>().connectToDevice(device);
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

  Widget _buildConnectedView(BuildContext context, Device device) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_connected, size: 48.r, color: Colors.green),
          SizedBox(height: 16.h),
          Text(
            'Connected to ${device.name ?? 'Unknown Device'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ElevatedButton(
            onPressed: () {
              context.go('/control');
            },
            child: const Text('Go to Arm Controller'),
          ),

          SizedBox(height: 8.h),
          ElevatedButton(
            onPressed: () {
              context.go('/control3d');
            },
            child: const Text('Open 3D Arm Viewer'),
          ),

          SizedBox(height: 8.h),
          ElevatedButton(
            onPressed: () => context.read<BluetoothCubit>().disconnect(),
            child: const Text('Disconnect'),
          ),
        ],
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
