import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandPrimary = AppColors.brandPrimary(isDark);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.privacy_tip, color: brandPrimary, size: 28.sp),
              SizedBox(width: 12.w),
              Text(
                'privacy_title'.tr(),
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'privacy_subtitle'.tr(),
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 20.h),

          // Section 1
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
                  Text(
                    'privacy_section_1_title'.tr(),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: brandPrimary),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'privacy_section_1_desc'.tr(),
                    style: TextStyle(fontSize: 14.sp, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Section 2
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
                  Text(
                    'privacy_section_2_title'.tr(),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: brandPrimary),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'privacy_section_2_desc'.tr(),
                    style: TextStyle(fontSize: 14.sp, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Section 3
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
                  Text(
                    'privacy_section_3_title'.tr(),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: brandPrimary),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'privacy_section_3_desc'.tr(),
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
