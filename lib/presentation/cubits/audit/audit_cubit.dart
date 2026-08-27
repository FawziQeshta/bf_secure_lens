import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/security_issue.dart';
import '../../../domain/usecases/run_security_audit_usecase.dart';
import '../../../domain/usecases/export_audit_report_usecase.dart';
import '../../../core/utils/report_exporter.dart';
import 'audit_state.dart';

class AuditCubit extends Cubit<AuditState> {
  final RunSecurityAuditUseCase runSecurityAuditUseCase;
  final ExportAuditReportUseCase exportAuditReportUseCase;

  AuditCubit({
    required this.runSecurityAuditUseCase,
    required this.exportAuditReportUseCase,
  }) : super(AuditInitialState());

  Future<void> startAudit(String targetPath) async {
    if (targetPath.isEmpty) {
      emit(const AuditErrorState('invalid_path'));
      return;
    }

    emit(const AuditScanningState(currentScanningFile: '', scannedCount: 0));

    try {
      final result = await runSecurityAuditUseCase(
        targetPath,
        onProgress: (currentFile, count) {
          emit(AuditScanningState(currentScanningFile: currentFile, scannedCount: count));
        },
      );

      emit(AuditSuccessState(scanResult: result));
    } catch (e) {
      emit(AuditErrorState(e.toString()));
    }
  }

  void filterBySeverity(Severity? severity) {
    if (state is AuditSuccessState) {
      final currentState = state as AuditSuccessState;
      emit(currentState.copyWith(
        selectedSeverity: severity,
        clearSeverity: severity == null,
      ));
    }
  }

  void filterByCategory(IssueCategory? category) {
    if (state is AuditSuccessState) {
      final currentState = state as AuditSuccessState;
      emit(currentState.copyWith(
        selectedCategory: category,
        clearCategory: category == null,
      ));
    }
  }

  void setSearchQuery(String query) {
    if (state is AuditSuccessState) {
      final currentState = state as AuditSuccessState;
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  Future<void> exportReport(String outputPath, ExportFormat format) async {
    if (state is AuditSuccessState) {
      final currentState = state as AuditSuccessState;
      try {
        final path = await exportAuditReportUseCase(currentState.scanResult, outputPath, format);
        emit(ReportExportedState(path));
        // Return to success state
        emit(currentState);
      } catch (e) {
        emit(AuditErrorState(e.toString()));
      }
    }
  }
}
