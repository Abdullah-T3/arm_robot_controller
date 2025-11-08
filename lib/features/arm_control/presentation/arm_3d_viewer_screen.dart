import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class Arm3DViewerScreen extends StatelessWidget {
  const Arm3DViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arm 3D Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () => context.go('/scan'),
          ),
        ],
      ),
      body: const _Arm3DViewerBody(),
    );
  }
}

class _Arm3DViewerBody extends StatelessWidget {
  const _Arm3DViewerBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1F2937),
                  Color(0xFF111827),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.view_in_ar,
                    size: 64.r,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '3D Viewer Placeholder',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8.h),
                  const Text(
                    'Provide an arm GLB and enable a viewer to render it.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const _ViewerHelpBar(),
      ],
    );
  }
}

class _ViewerHelpBar extends StatelessWidget {
  const _ViewerHelpBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instructions',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4.h),
          const Text(
            'This screen is ready to host a high-quality arm model with PBR textures and rigging. Once the viewer package is available, we can render the GLB and add controls.',
          ),
        ],
      ),
    );
  }
}