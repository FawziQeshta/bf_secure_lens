import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('copied_to_clipboard'.tr()),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandPrimary = AppColors.brandPrimary(isDark);
    final whatsappColor = AppColors.secureBoxText(isDark);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.headset_mic, color: brandPrimary, size: 28.sp),
              SizedBox(width: 12.w),
              Text(
                'contact_title'.tr(),
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'contact_subtitle'.tr(),
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 20.h),

          // WhatsApp Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: whatsappColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.chat, color: whatsappColor, size: 28.sp),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'whatsapp'.tr(),
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.h),
                        SelectableText(
                          'whatsapp_number'.tr(),
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.copy, size: 16.sp),
                    label: Text('copy'.tr()),
                    onPressed: () => _copyToClipboard(context, 'whatsapp_number'.tr()),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Email Support Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: brandPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.email, color: brandPrimary, size: 28.sp),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'email'.tr(),
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.h),
                        SelectableText(
                          'email_address'.tr(),
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.copy, size: 16.sp),
                    label: Text('copy'.tr()),
                    onPressed: () => _copyToClipboard(context, 'email_address'.tr()),
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
