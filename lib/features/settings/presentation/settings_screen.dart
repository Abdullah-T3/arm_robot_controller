import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bluetooth/cubit/bluetooth_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          _modernSection(
            context,
            title: 'CONNECTION',
            children: [
              ListTile(
                title: const Text('Connected Device'),
                subtitle: BlocBuilder<BluetoothCubit, BluetoothState>(
                  builder: (context, state) {
                    return Text(
                      state is BluetoothConnected
                          ? state.device.name ?? 'Unknown Device'
                          : 'Not Connected',
                    );
                  },
                ),
                trailing: TextButton(
                  onPressed: () => context.read<BluetoothCubit>().disconnect(),
                  child: const Text('Disconnect'),
                ),
              ),
              SwitchListTile(
                title: const Text('Auto-connect on startup'),
                value: true, // Replace with actual value
                onChanged: (value) {
                  // Handle auto-connect setting
                },
              ),
            ],
          ),
          _modernSection(
            context,
            title: 'APPEARANCE',
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: true, // Replace with actual theme mode
                onChanged: (value) {
                  // Handle theme mode change
                },
              ),
            ],
          ),
          _modernSection(
            context,
            title: 'ABOUT',
            children: [
              ListTile(
                title: const Text('App Version'),
                trailing: const Text('1.0.2'),
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16.r),
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              ListTile(
                title: const Text('Terms of Service'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16.r),
                onTap: () {
                  // Navigate to terms of service
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _modernSection(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 12.r),
      color: Theme.of(context).colorScheme.surface.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
