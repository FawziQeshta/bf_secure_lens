import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/security_issue.dart';

class GuidelineCardWidget extends StatelessWidget {
  final SecurityGuideline guide;

  const GuidelineCardWidget({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandPrimary = AppColors.brandPrimary(isDark);
    final brandSecondary = AppColors.brandSecondary(isDark);

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  guide.title,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: brandPrimary),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: brandPrimary),
                  ),
                  child: Text(
                    guide.platform,
                    style: TextStyle(color: brandPrimary, fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              guide.summary,
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 14.h),
            Text(
              'action_checklist'.tr(),
              style: TextStyle(color: brandSecondary, fontWeight: FontWeight.bold, fontSize: 13.sp),
            ),
            SizedBox(height: 6.h),
            ...guide.checklist.map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: brandSecondary, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                    Expanded(
                      child: Text(item, style: TextStyle(fontSize: 13.sp)),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'code_template'.tr(),
                  style: TextStyle(color: AppColors.secureBoxText(isDark), fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
                IconButton(
                  icon: Icon(Icons.copy, size: 16.sp, color: brandPrimary),
                  tooltip: 'copy_template'.tr(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: guide.codeSnippet));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('snippet_copied'.tr())),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.codeBoxBackground(isDark),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: SelectableText(
                guide.codeSnippet.trim(),
                style: TextStyle(fontFamily: 'monospace', color: AppColors.secureBoxText(isDark), fontSize: 12.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
