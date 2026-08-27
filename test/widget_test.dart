import 'package:flutter_test/flutter_test.dart';
import 'package:bf_secure_lens/data/datasources/local_scanner_datasource.dart';
import 'package:bf_secure_lens/data/repositories/security_audit_repository_impl.dart';
import 'package:bf_secure_lens/domain/usecases/run_security_audit_usecase.dart';
import 'package:bf_secure_lens/domain/entities/security_issue.dart';
import 'package:bf_secure_lens/services/scanners/secret_scanner.dart';
import 'package:bf_secure_lens/services/scanners/manifest_scanner.dart';
import 'package:bf_secure_lens/services/scanners/code_quality_scanner.dart';

void main() {
  group('Clean Architecture Security Scanner & Health Score Unit Tests', () {
    late LocalScannerDataSource localScannerDataSource;
    late SecurityAuditRepositoryImpl repository;
    late RunSecurityAuditUseCase runSecurityAuditUseCase;

    setUp(() {
      localScannerDataSource = LocalScannerDataSourceImpl();
      repository = SecurityAuditRepositoryImpl(localScannerDataSource: localScannerDataSource);
      runSecurityAuditUseCase = RunSecurityAuditUseCase(repository);
    });

    test('Executes security audit use case on single file', () async {
      final result = await runSecurityAuditUseCase('lib/main.dart');
      expect(result.totalFilesScanned, equals(1));
      expect(result.issues, isA<List<SecurityIssue>>());
    });

    test('Retrieves hardening guidelines from repository', () {
      final guides = repository.getHardeningGuides();
      expect(guides.isNotEmpty, isTrue);
      expect(guides.first.title.isNotEmpty, isTrue);
    });

    test('Accurately detects Secrets, Manifest Misconfigurations, and Code Vulnerabilities', () {
      final secretScanner = SecretScanner();
      final manifestScanner = ManifestScanner();
      final codeScanner = CodeQualityScanner();

      // 1. Detect AWS Key Secret
      final secretIssues = secretScanner.scan('config.dart', 'final key = "AKIA1234567890123456";');
      expect(secretIssues.isNotEmpty, isTrue);
      expect(secretIssues.first.title, contains('AWS Access Key'));

      // 2. Detect Android Debuggable & Cleartext Manifest Misconfigurations
      final manifestIssues = manifestScanner.scan(
        'AndroidManifest.xml',
        '<application android:debuggable="true" android:usesCleartextTraffic="true">',
      );
      expect(manifestIssues.length, equals(2));

      // 3. Detect Laravel APP_DEBUG=true
      final envIssues = manifestScanner.scan('.env', 'APP_DEBUG=true\nAPP_KEY=');
      expect(envIssues.length, equals(2));

      // 4. Detect C# SQL Injection in ASP.NET
      final csIssues = codeScanner.scan('UserController.cs', r'''context.Users.FromSqlRaw($"SELECT * FROM Users WHERE Name = '{userInput}'");''');
      expect(csIssues.isNotEmpty, isTrue);
      expect(csIssues.first.category, equals(IssueCategory.codeQuality));

      // 5. Detect PHP SQL Injection & eval() RCE
      final phpIssues = codeScanner.scan('api.php', r'$res = mysqli_query($conn, "SELECT * FROM users WHERE id=" . $_GET["id"]); eval($code);');
      expect(phpIssues.length, equals(3));
    });

    test('Calculates security health score correctly based on issue severities', () {
      // 1. Perfect score when no issues exist
      final cleanResult = ScanResult(
        targetPath: 'lib/',
        scanTime: DateTime.now(),
        issues: const [],
        totalFilesScanned: 10,
        scanDuration: const Duration(milliseconds: 50),
      );
      expect(cleanResult.securityScore, equals(100));

      // 2. Score with 1 Critical issue (-25 points)
      final criticalResult = ScanResult(
        targetPath: 'lib/',
        scanTime: DateTime.now(),
        issues: const [
          SecurityIssue(
            id: '1',
            title: 'Critical Leak',
            description: 'Desc',
            category: IssueCategory.secrets,
            severity: Severity.critical,
            filePath: 'file.dart',
            lineNumber: 10,
            snippet: 'AKIA1234567890123456',
            remediationAdvice: 'Remediation',
            secureCodeExample: 'Fix',
            cweOrOwasp: 'CWE-798',
          )
        ],
        totalFilesScanned: 1,
        scanDuration: const Duration(milliseconds: 10),
      );
      expect(criticalResult.securityScore, equals(75));

      // 3. Score with 1 High issue (-15 points)
      final highResult = ScanResult(
        targetPath: 'lib/',
        scanTime: DateTime.now(),
        issues: const [
          SecurityIssue(
            id: '2',
            title: 'High Gap',
            description: 'Desc',
            category: IssueCategory.networkSecurity,
            severity: Severity.high,
            filePath: 'file.dart',
            lineNumber: 12,
            snippet: 'http://api.com',
            remediationAdvice: 'Remediation',
            secureCodeExample: 'Fix',
            cweOrOwasp: 'CWE-319',
          )
        ],
        totalFilesScanned: 1,
        scanDuration: const Duration(milliseconds: 10),
      );
      expect(highResult.securityScore, equals(85));

      // 4. Score clamped to 0 when penalty exceeds 100
      final severeResult = ScanResult(
        targetPath: 'lib/',
        scanTime: DateTime.now(),
        issues: List.generate(
          10,
          (i) => SecurityIssue(
            id: '$i',
            title: 'Critical Issue $i',
            description: 'Desc',
            category: IssueCategory.secrets,
            severity: Severity.critical,
            filePath: 'file.dart',
            lineNumber: i + 1,
            snippet: 'Secret',
            remediationAdvice: 'Fix',
            secureCodeExample: 'Fix',
            cweOrOwasp: 'CWE-798',
          ),
        ),
        totalFilesScanned: 5,
        scanDuration: const Duration(milliseconds: 20),
      );
      expect(severeResult.securityScore, equals(0));
    });
  });
}
