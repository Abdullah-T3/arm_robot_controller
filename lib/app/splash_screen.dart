import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/scan');
    });
  }

  @override
  Widget build(BuildContext context) {
    final names = const [
      'Abdullah ahmed hassan',
      'Abdelrahman yehia ibrahim ',
      'Merna Bahgat Naeem',
      'Demiana samy maawad',
      'Mariam sayed sayed',
      'Hamed mohamed hamed',
      'Jassmn wael abdelaziz',
      'Omar Sayed Mahmoud',
      'Mohamed hatem',
      'Ismail mohamed ismail',
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.background.withOpacity(0.9),
              Theme.of(context).colorScheme.surface.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 32.h),
                Text(
                  'Contributors',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Robot Arm Controller',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 28.h),
                Expanded(
                  child: ListView.separated(
                    itemCount: names.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 400 + index * 40),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 16.w,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14.r,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.85),
                                child: Text(
                                  '${index + 1}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  names[index],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Starting…',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
