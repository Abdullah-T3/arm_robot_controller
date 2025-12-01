import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../bluetooth/providers/bluetooth_provider.dart';
import '../../bluetooth/models/bluetooth_state.dart';
import '../providers/settings_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                subtitle: Consumer(
                  builder: (context, ref, child) {
                    final state = ref.watch(bluetoothProvider);
                    return Text(
                      state.whenOrNull(
                            connected: (device) =>
                                device.name ?? 'Unknown Device',
                          ) ??
                          'Not Connected',
                    );
                  },
                ),
                trailing: TextButton(
                  onPressed: () =>
                      ref.read(bluetoothProvider.notifier).disconnect(),
                  child: const Text('Disconnect'),
                ),
              ),
              SwitchListTile(
                title: const Text('Auto-connect on startup'),
                value: ref.watch(settingsProvider).autoConnect,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setAutoConnect(value);
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
                value: ref.watch(settingsProvider).darkMode,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setDarkMode(value);
                },
              ),
            ],
          ),
          _modernSection(
            context,
            title: 'CONTRIBUTORS',
            children: [
              ...const [
                'Abdullah ahmed hassan',
                'Abdelrahman yehia ibrahim ',
                'Merna Bahgat Naeem',
                'Demiana samy maawad',
                'Mariam',
                'Hamed mohamed hamed',
                'Jassmn wael abdelaziz',
                'Omar Sayed Mahmoud',
                'Mohamed hatem',
                'Ismail mohamed ismail',
              ].map((name) => ListTile(title: Text(name))),
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

  Widget _modernSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
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
