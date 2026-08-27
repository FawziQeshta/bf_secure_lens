import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/security_issue.dart';

class IssueCardWidget extends StatefulWidget {
  final SecurityIssue issue;

  const IssueCardWidget({super.key, required this.issue});

  @override
  State<IssueCardWidget> createState() => _IssueCardWidgetState();
}

class _IssueCardWidgetState extends State<IssueCardWidget> {
  bool _isExpanded = false;

  Color _getSeverityColor(bool isDark) {
    switch (widget.issue.severity) {
      case Severity.critical:
        return isDark ? AppColors.darkCritical : AppColors.lightCritical;
      case Severity.high:
        return isDark ? AppColors.darkHigh : AppColors.lightHigh;
      case Severity.medium:
        return isDark ? AppColors.darkMedium : AppColors.lightMedium;
      case Severity.low:
        return isDark ? AppColors.darkLow : AppColors.lightLow;
      case Severity.info:
        return isDark ? AppColors.darkInfo : AppColors.lightInfo;
    }
  }

  IconData get _severityIcon {
    switch (widget.issue.severity) {
      case Severity.critical:
        return Icons.dangerous;
      case Severity.high:
        return Icons.warning_amber_rounded;
      case Severity.medium:
        return Icons.info_outline;
      case Severity.low:
        return Icons.shield_outlined;
      case Severity.info:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final severityColor = _getSeverityColor(isDark);
    final brandPrimary = AppColors.brandPrimary(isDark);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 2.w),
      elevation: isDark ? 1 : 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(color: severityColor.withValues(alpha: isDark ? 0.4 : 0.3), width: 1.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: severityColor, width: 1.w),
                  ),
                  child: Row(
                    children: [
                      Icon(_severityIcon, size: 16.sp, color: severityColor),
                      SizedBox(width: 6.w),
                      Text(
                        issue.severity.name.toUpperCase(),
                        style: TextStyle(
                          color: severityColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    issue.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey, size: 20.sp),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.folder_open, size: 14.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    '${issue.filePath}:${issue.lineNumber}',
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp, fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: brandPrimary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    issue.cweOrOwasp,
                    style: TextStyle(color: brandPrimary, fontSize: 11.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              issue.description,
              style: TextStyle(fontSize: 13.sp),
            ),
            if (_isExpanded) ...[
              Divider(height: 24.h),
              Text(
                'vulnerable_snippet'.tr(),
                style: TextStyle(color: AppColors.vulnerableBoxText(isDark), fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
              SizedBox(height: 4.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.vulnerableBoxBackground(isDark),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.vulnerableBoxBorder(isDark)),
                ),
                child: SelectableText(
                  issue.snippet,
                  style: TextStyle(fontFamily: 'monospace', color: AppColors.vulnerableBoxText(isDark), fontSize: 12.sp),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'remediation_advice'.tr(),
                style: TextStyle(color: AppColors.secureBoxText(isDark), fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                issue.remediationAdvice,
                style: TextStyle(fontSize: 13.sp),
              ),
              SizedBox(height: 10.h),
              Text(
                'recommended_fix'.tr(),
                style: TextStyle(color: brandPrimary, fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
              SizedBox(height: 4.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.secureBoxBackground(isDark),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.secureBoxBorder(isDark)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SelectableText(
                        issue.secureCodeExample,
                        style: TextStyle(fontFamily: 'monospace', color: AppColors.secureBoxText(isDark), fontSize: 12.sp),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, size: 16.sp, color: brandPrimary),
                      tooltip: 'copy_fix'.tr(),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: issue.secureCodeExample));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('snippet_copied'.tr()),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
