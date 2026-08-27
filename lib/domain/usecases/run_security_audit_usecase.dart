import '../entities/security_issue.dart';
import '../repositories/security_audit_repository.dart';

class RunSecurityAuditUseCase {
  final SecurityAuditRepository repository;

  RunSecurityAuditUseCase(this.repository);

  Future<ScanResult> call(
    String targetPath, {
    void Function(String currentFile, int count)? onProgress,
  }) {
    return repository.runSecurityAudit(targetPath, onProgress: onProgress);
  }
}
