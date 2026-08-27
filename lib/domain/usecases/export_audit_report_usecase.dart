import '../entities/security_issue.dart';
import '../repositories/security_audit_repository.dart';
import '../../core/utils/report_exporter.dart';

class ExportAuditReportUseCase {
  final SecurityAuditRepository repository;

  ExportAuditReportUseCase(this.repository);

  Future<String> call(ScanResult result, String outputPath, ExportFormat format) {
    return repository.exportReport(result, outputPath, format);
  }
}
