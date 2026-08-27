import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/report_exporter.dart';
import '../../../domain/entities/security_issue.dart';
import '../../cubits/audit/audit_cubit.dart';
import '../../cubits/audit/audit_state.dart';
import '../issues/widgets/issue_card_widget.dart';
import 'widgets/score_gauge_widget.dart';
import 'widgets/metric_card_widget.dart';

class DashboardScreen extends StatefulWidget {
  final TextEditingController pathController;

  const DashboardScreen({super.key, required this.pathController});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> _pickDirectory() async {
    final selectedDirectory = await FilePicker.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        widget.pathController.text = selectedDirectory;
      });
    }
  }

  Future<void> _exportReport(BuildContext context, ScanResult result) async {
    final pdfBytes = await ReportExporter.generatePdf(result);

    final savedUri = await FilePicker.saveFile(
      dialogTitle: 'export_report'.tr(),
      fileName:
          'security_audit_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      bytes: pdfBytes,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'md', 'json'],
    );

    if (savedUri != null && context.mounted) {
      final filePath = savedUri.toFilePath();
      final lowerPath = filePath.toLowerCase();
      final ExportFormat format = lowerPath.endsWith('.json')
          ? ExportFormat.json
          : lowerPath.endsWith('.md')
          ? ExportFormat.markdown
          : ExportFormat.pdf;

      context.read<AuditCubit>().exportReport(filePath, format);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandPrimary = AppColors.brandPrimary(isDark);

    return BlocConsumer<AuditCubit, AuditState>(
      listener: (context, state) {
        if (state is AuditErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message == 'invalid_path'
                    ? 'valid_path_error'.tr()
                    : 'scan_failed'.tr(args: [state.message]),
              ),
            ),
          );
        } else if (state is ReportExportedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('report_exported'.tr(args: [state.filePath])),
            ),
          );
        }
      },
      builder: (context, state) {
        final isScanning = state is AuditScanningState;
        final currentScanningFile = isScanning ? state.currentScanningFile : '';
        final scannedCount = isScanning ? state.scannedCount : 0;
        final result = state is AuditSuccessState ? state.scanResult : null;

        return SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner Card
              Card(
                elevation: isDark ? 1 : 0.5,
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
                          Icon(Icons.shield, color: brandPrimary, size: 28.sp),
                          SizedBox(width: 12.w),
                          Text(
                            'header_title'.tr(),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'header_subtitle'.tr(),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: widget.pathController,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontFamily: 'monospace',
                              ),
                              decoration: InputDecoration(
                                hintText: 'path_hint'.tr(),
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          ElevatedButton.icon(
                            icon: Icon(Icons.folder_open, size: 18.sp),
                            label: Text('browse'.tr()),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 14.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            onPressed: isScanning ? null : _pickDirectory,
                          ),
                          SizedBox(width: 12.w),
                          ElevatedButton.icon(
                            icon: isScanning
                                ? SizedBox(
                                    width: 18.w,
                                    height: 18.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: isDark
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  )
                                : Icon(Icons.search, size: 18.sp),
                            label: Text(
                              isScanning ? 'scanning'.tr() : 'start_audit'.tr(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandPrimary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 14.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            onPressed: isScanning
                                ? null
                                : () => context.read<AuditCubit>().startAudit(
                                    widget.pathController.text.trim(),
                                  ),
                          ),
                        ],
                      ),
                      if (isScanning) ...[
                        SizedBox(height: 16.h),
                        LinearProgressIndicator(
                          backgroundColor: Theme.of(context).dividerColor,
                          color: brandPrimary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'scanned_files'.tr(
                            args: [
                              scannedCount.toString(),
                              currentScanningFile,
                            ],
                          ),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.sp,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              if (result != null) ...[
                // Score & Metric Cards
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ScoreGaugeWidget(score: result.securityScore),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          MetricCardWidget(
                            label: 'critical_gaps'.tr(),
                            value: result.criticalCount.toString(),
                            color: isDark
                                ? AppColors.darkCritical
                                : AppColors.lightCritical,
                          ),
                          SizedBox(width: 8.w),
                          MetricCardWidget(
                            label: 'high_gaps'.tr(),
                            value: result.highCount.toString(),
                            color: isDark
                                ? AppColors.darkHigh
                                : AppColors.lightHigh,
                          ),
                          SizedBox(width: 8.w),
                          MetricCardWidget(
                            label: 'medium_low'.tr(),
                            value: (result.mediumCount + result.lowCount)
                                .toString(),
                            color: isDark
                                ? AppColors.darkMedium
                                : AppColors.lightMedium,
                          ),
                          SizedBox(width: 8.w),
                          MetricCardWidget(
                            label: 'files_scanned'.tr(),
                            value: result.totalFilesScanned.toString(),
                            color: brandPrimary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'audit_findings'.tr(
                        args: [result.issues.length.toString()],
                      ),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.picture_as_pdf, size: 16.sp),
                      label: Text('export_report'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandPrimary.withValues(alpha: 0.1),
                        foregroundColor: brandPrimary,
                        elevation: 0,
                      ),
                      onPressed: () => _exportReport(context, result),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                if (result.issues.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(30.r),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: isDark
                              ? AppColors.darkInfo
                              : AppColors.lightInfo,
                          size: 48.sp,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'no_gaps'.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: result.issues.length,
                    itemBuilder: (context, index) {
                      return IssueCardWidget(issue: result.issues[index]);
                    },
                  ),
              ] else ...[
                // Empty state placeholder
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(50.r),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security, size: 64.sp, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text(
                        'no_results_yet'.tr(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'select_prompt'.tr(),
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
