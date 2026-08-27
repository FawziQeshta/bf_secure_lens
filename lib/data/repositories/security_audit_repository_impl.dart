import '../../domain/entities/security_issue.dart';
import '../../domain/repositories/security_audit_repository.dart';
import '../../services/advisory_service.dart';
import '../../core/utils/report_exporter.dart';
import '../datasources/local_scanner_datasource.dart';

class SecurityAuditRepositoryImpl implements SecurityAuditRepository {
  final LocalScannerDataSource localScannerDataSource;

  SecurityAuditRepositoryImpl({required this.localScannerDataSource});

  @override
  Future<ScanResult> runSecurityAudit(
    String targetPath, {
    void Function(String currentFile, int count)? onProgress,
  }) {
    return localScannerDataSource.scanPath(targetPath, onProgress: onProgress);
  }

  @override
  Future<String> exportReport(ScanResult result, String outputPath, ExportFormat format) {
    switch (format) {
      case ExportFormat.pdf:
        return ReportExporter.exportToPdf(result, outputPath);
      case ExportFormat.json:
        return ReportExporter.exportToJson(result, outputPath);
      case ExportFormat.markdown:
        return ReportExporter.exportToMarkdown(result, outputPath);
    }
  }

  @override
  List<SecurityGuideline> getHardeningGuides() {
    return AdvisoryService.hardeningGuides;
  }
}
