import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../arm_control/cubit/arm_control_cubit.dart';
import '../cubit/presets_cubit.dart';
import '../cubit/presets_state.dart';
import '../data/preset_repository.dart';
import '../models/preset.dart';

class PresetsScreen extends StatelessWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PresetsCubit(HivePresetRepository())..load(),
      child: const _PresetsView(),
    );
  }
}

class _PresetsView extends StatelessWidget {
  const _PresetsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Presets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () => context.read<PresetsCubit>().undo(),
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: () => context.read<PresetsCubit>().redo(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePresetDialog(context),
        label: const Text('Create Preset'),
        icon: const Icon(Icons.add),
      ),
      body: BlocConsumer<PresetsCubit, PresetsState>(
        listener: (context, state) {
          if (state is PresetsLoaded && state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
          }
          if (state is PresetsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PresetsLoading || state is PresetsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PresetsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  SizedBox(height: 8.h),
                  Text(state.message),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<PresetsCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final presets = (state as PresetsLoaded).presets;
          if (presets.isEmpty) {
            return const Center(
              child: Text('No presets yet. Tap + to create.'),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final p = presets[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12.r),
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.save,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _formatPositions(p.positions),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    TextButton(
                      onPressed: () => _showEditPresetDialog(context, p),
                      child: const Text('Edit'),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      onPressed: () => _applyPreset(context, p),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmation(context, p),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatPositions(List<double> pos) {
    final labels = ['Base', 'Shoulder', 'Elbow', 'Wrist', 'Gripper'];
    return List.generate(
      pos.length,
      (i) => '${labels[i]}: ${pos[i].round()}°',
    ).join(', ');
  }

  void _applyPreset(BuildContext context, Preset p) {
    // Map to ArmControlCubit model
    context.read<ArmControlCubit>().loadPreset(
      ServoPreset(name: p.name, positions: p.positions),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Applied ${p.name}')));
  }

  Future<void> _showCreatePresetDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final arm = context.read<ArmControlCubit>();
    final positions = arm.state.servoPositions;

    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Create Preset'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: [
            TextButton(onPressed: () => ctx.pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Name is required')),
                  );
                  return;
                }
                await context.read<PresetsCubit>().createPreset(
                  name,
                  positions,
                );
                ctx.pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditPresetDialog(
    BuildContext context,
    Preset preset,
  ) async {
    final nameController = TextEditingController(text: preset.name);
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Preset'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: [
            TextButton(onPressed: () => ctx.pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Name is required')),
                  );
                  return;
                }
                await context.read<PresetsCubit>().updatePreset(
                  id: preset.id,
                  name: name,
                );
                ctx.pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Preset preset,
  ) async {
    return showDialog(
      context: context,
      useRootNavigator: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Preset?'),
          content: Text(
            'Delete "${preset.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(child: const Text('Cancel'), onPressed: () => ctx.pop()),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await context.read<PresetsCubit>().deletePreset(preset.id);
                ctx.pop();
              },
            ),
          ],
        );
      },
    );
  }
}
