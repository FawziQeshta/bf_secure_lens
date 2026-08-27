import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MetricCardWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const MetricCardWidget({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: color),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(fontSize: 11.sp),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
