import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../cubits/audit/audit_cubit.dart';
import '../../cubits/audit/audit_state.dart';
import 'widgets/issue_card_widget.dart';
import 'widgets/issue_filter_bar.dart';

class IssuesScreen extends StatelessWidget {
  const IssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuditCubit, AuditState>(
      builder: (context, state) {
        if (state is! AuditSuccessState) {
          return Center(
            child: Text(
              'run_audit_first'.tr(),
              style: TextStyle(color: Colors.grey, fontSize: 16.sp),
            ),
          );
        }

        final filteredIssues = state.filteredIssues;
        final totalIssues = state.scanResult.issues.length;

        return Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IssueFilterBar(
                selectedSeverity: state.selectedSeverity,
                selectedCategory: state.selectedCategory,
                onSearchChanged: (val) => context.read<AuditCubit>().setSearchQuery(val),
                onSeverityChanged: (sev) => context.read<AuditCubit>().filterBySeverity(sev),
                onCategoryChanged: (cat) => context.read<AuditCubit>().filterByCategory(cat),
              ),
              SizedBox(height: 16.h),
              Text(
                'showing_issues'.tr(args: [filteredIssues.length.toString(), totalIssues.toString()]),
                style: TextStyle(color: Colors.grey, fontSize: 13.sp),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: filteredIssues.isEmpty
                    ? Center(
                        child: Text(
                          'no_matching_issues'.tr(),
                          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredIssues.length,
                        itemBuilder: (context, index) {
                          return IssueCardWidget(issue: filteredIssues[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
