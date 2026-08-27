import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandPrimary = AppColors.brandPrimary(isDark);
    final brandSecondary = AppColors.brandSecondary(isDark);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/icon_app.png',
                width: 36.w,
                height: 36.h,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.info_outline, color: brandPrimary, size: 32.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                'about_title'.tr(),
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // About Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.groups, color: brandPrimary, size: 24.sp),
                      SizedBox(width: 10.w),
                      Text(
                        'bf_team'.tr(),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: brandPrimary),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'about_description'.tr(),
                    style: TextStyle(fontSize: 14.sp, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Mission Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.track_changes, color: brandSecondary, size: 24.sp),
                      SizedBox(width: 10.w),
                      Text(
                        'our_mission'.tr(),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: brandSecondary),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'mission_desc'.tr(),
                    style: TextStyle(fontSize: 14.sp, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
