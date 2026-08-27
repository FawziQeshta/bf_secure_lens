import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';

class ScoreGaugeWidget extends StatelessWidget {
  final int score;

  const ScoreGaugeWidget({super.key, required this.score});

  Color _getScoreColor(bool isDark) {
    if (score >= 85) return isDark ? AppColors.darkInfo : AppColors.lightInfo;
    if (score >= 60) return isDark ? AppColors.darkHigh : AppColors.lightHigh;
    return isDark ? AppColors.darkCritical : AppColors.lightCritical;
  }

  String get _scoreDescription {
    if (score >= 85) return 'score_good'.tr();
    if (score >= 60) return 'score_moderate'.tr();
    return 'score_high'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scoreColor = _getScoreColor(isDark);
    final clampedValue = (score / 100.0).clamp(0.0, 1.0);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: scoreColor.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80.r,
                  height: 80.r,
                  child: CircularProgressIndicator(
                    value: clampedValue,
                    strokeWidth: 8.r,
                    backgroundColor: Theme.of(context).dividerColor,
                    color: scoreColor,
                  ),
                ),
                Text(
                  '$score%',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'security_health_score'.tr(),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _scoreDescription,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
