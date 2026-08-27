import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../domain/entities/security_issue.dart';

class IssueFilterBar extends StatelessWidget {
  final Severity? selectedSeverity;
  final IssueCategory? selectedCategory;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Severity?> onSeverityChanged;
  final ValueChanged<IssueCategory?> onCategoryChanged;

  const IssueFilterBar({
    super.key,
    required this.selectedSeverity,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onSeverityChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            style: TextStyle(fontSize: 14.sp),
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'search_hint'.tr(),
              prefixIcon: Icon(Icons.search, size: 20.sp),
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        DropdownButton<Severity?>(
          value: selectedSeverity,
          hint: Text('all_severities'.tr(), style: TextStyle(fontSize: 13.sp)),
          items: [
            DropdownMenuItem<Severity?>(
              value: null,
              child: Text('all_severities'.tr(), style: TextStyle(fontSize: 13.sp)),
            ),
            ...Severity.values.map((sev) {
              return DropdownMenuItem<Severity?>(
                value: sev,
                child: Text(sev.name.toUpperCase(), style: TextStyle(fontSize: 13.sp)),
              );
            }),
          ],
          onChanged: onSeverityChanged,
        ),
        SizedBox(width: 12.w),
        DropdownButton<IssueCategory?>(
          value: selectedCategory,
          hint: Text('all_categories'.tr(), style: TextStyle(fontSize: 13.sp)),
          items: [
            DropdownMenuItem<IssueCategory?>(
              value: null,
              child: Text('all_categories'.tr(), style: TextStyle(fontSize: 13.sp)),
            ),
            ...IssueCategory.values.map((cat) {
              return DropdownMenuItem<IssueCategory?>(
                value: cat,
                child: Text(cat.name, style: TextStyle(fontSize: 13.sp)),
              );
            }),
          ],
          onChanged: onCategoryChanged,
        ),
      ],
    );
  }
}
