import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:arm_robot_controller/features/arm_control/cubit/arm_control_cubit.dart';
import 'widgets/arm_visualizer.dart';
import 'widgets/hover_slider.dart';

class ArmControlScreen extends StatefulWidget {
  const ArmControlScreen({super.key});

  @override
  State<ArmControlScreen> createState() => _ArmControlScreenState();
}

class _ArmControlScreenState extends State<ArmControlScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RoboArm Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () => context.go('/scan'),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: BlocBuilder<ArmControlCubit, ArmControlState>(
        builder: (context, state) {
          final ranges = _jointRanges;
          return LayoutBuilder(
            builder: (context, constraints) {
              // Use a lower threshold so phones in landscape render wide layout
              final wide = constraints.maxWidth >= 700;
              final vis = Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                color: Theme.of(context).colorScheme.surface.withOpacity(0.06),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: AspectRatio(
                    // Slightly wider ratio in landscape for better use of space
                    aspectRatio: wide ? 1.4 : 1.0,
                    child: AnimatedArmVisualizer(angles: state.servoPositions),
                  ),
                ),
              );

              // Controls content reused for wide and narrow layouts
              final controlsContent = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Manual Control',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _slider(
                    context,
                    ranges[0].label,
                    0,
                    ranges[0].min,
                    ranges[0].max,
                  ),
                  SizedBox(height: 8.h),
                  _slider(
                    context,
                    ranges[1].label,
                    1,
                    ranges[1].min,
                    ranges[1].max,
                  ),
                  SizedBox(height: 8.h),
                  _slider(
                    context,
                    ranges[2].label,
                    2,
                    ranges[2].min,
                    ranges[2].max,
                  ),
                  SizedBox(height: 8.h),
                  _slider(
                    context,
                    ranges[3].label,
                    3,
                    ranges[3].min,
                    ranges[3].max,
                  ),
                  SizedBox(height: 8.h),
                  _slider(
                    context,
                    ranges[4].label,
                    4,
                    ranges[4].min,
                    ranges[4].max,
                    units: '°',
                  ),

                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Ask for preset name then save
                            showDialog(
                              context: context,
                              useRootNavigator: false,
                              builder: (ctx) {
                                final controller = TextEditingController();
                                return AlertDialog(
                                  title: const Text("Save Position"),
                                  content: TextField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      labelText: 'Preset Name',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => ctx.pop(),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final name = controller.text.trim();
                                        if (name.isEmpty) {
                                          ScaffoldMessenger.of(ctx).showSnackBar(
                                            const SnackBar(content: Text('Name is required')),
                                          );
                                          return;
                                        }
                                        context.read<ArmControlCubit>().saveCurrentPosition(name);
                                        ctx.pop();
                                      },
                                      child: const Text("Save"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('Save Position'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.push('/presets'),
                          child: const Text('View Presets'),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),
                  Text(
                    'Saved Positions',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (state.savedPositions.isEmpty)
                    Text(
                      'No saved positions yet. Use "Save Position" to add one.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    )
                  else
                    Column(
                      children: [
                        for (final p in state.savedPositions)
                          Container(
                            margin: EdgeInsets.only(bottom: 8.r),
                            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    p.name,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Apply',
                                  icon: const Icon(Icons.play_arrow),
                                  onPressed: () {
                                    context.read<ArmControlCubit>().loadPreset(p);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Applied ${p.name}')),
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    context.read<ArmControlCubit>().deletePreset(p);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Deleted ${p.name}')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              );

              final controlsWide = Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                color: Theme.of(context).colorScheme.surface.withOpacity(0.06),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: SingleChildScrollView(child: controlsContent),
                ),
              );

              final controlsNarrow = Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                color: Theme.of(context).colorScheme.surface.withOpacity(0.06),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: controlsContent,
                ),
              );

              return Padding(
                padding: EdgeInsets.all(16.r),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: vis),
                          SizedBox(width: 16.w),
                          Expanded(child: controlsWide),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [vis, controlsNarrow],
                        ),
                      ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _slider(
    BuildContext context,
    String label,
    int index,
    double min,
    double max, {
    String units = '°',
  }) {
    return BlocBuilder<ArmControlCubit, ArmControlState>(
      buildWhen: (prev, curr) =>
          prev.servoPositions[index] != curr.servoPositions[index],
      builder: (context, state) {
        final value = state.servoPositions[index];
        return HoverSlider(
          label: label,
          value: value,
          min: min,
          max: max,
          units: units,
          onChanged: (v) =>
              context.read<ArmControlCubit>().updateServoPosition(index, v),
        );
      },
    );
  }
}

class _JointRange {
  const _JointRange(this.label, this.min, this.max);
  final String label;
  final double min;
  final double max;
}

// Physical constraints for each joint
const List<_JointRange> _jointRanges = <_JointRange>[
  _JointRange('Base (Yaw)', 0, 180),
  _JointRange('Shoulder (Pitch)', 10, 170),
  _JointRange('Elbow (Pitch)', 0, 180),
  _JointRange('Wrist (Pitch)', 0, 180),
  _JointRange('Gripper (Open)', 0, 60),
];
