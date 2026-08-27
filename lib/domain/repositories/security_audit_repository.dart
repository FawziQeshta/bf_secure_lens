import '../entities/security_issue.dart';
import '../../core/utils/report_exporter.dart';

abstract class SecurityAuditRepository {
  Future<ScanResult> runSecurityAudit(
    String targetPath, {
    void Function(String currentFile, int count)? onProgress,
  });

  Future<String> exportReport(ScanResult result, String outputPath, ExportFormat format);

  List<SecurityGuideline> getHardeningGuides();
}
