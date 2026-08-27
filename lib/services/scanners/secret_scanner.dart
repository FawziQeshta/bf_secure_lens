import '../../domain/entities/security_issue.dart';

class SecretPattern {
  final String id;
  final String title;
  final RegExp pattern;
  final Severity severity;
  final String description;
  final String remediation;
  final String secureExample;
  final String cweOwasp;

  SecretPattern({
    required this.id,
    required this.title,
    required this.pattern,
    required this.severity,
    required this.description,
    required this.remediation,
    required this.secureExample,
    required this.cweOwasp,
  });
}

class SecretScanner {
  final List<SecretPattern> patterns = [
    SecretPattern(
      id: 'SEC-001',
      title: 'Hardcoded AWS Access Key',
      pattern: RegExp(r'''AKIA[0-9A-Z]{16}''', caseSensitive: false),
      severity: Severity.critical,
      description: 'An AWS Access Key ID was found embedded directly in the codebase.',
      remediation: 'Remove AWS credentials from source code immediately. Use AWS Secrets Manager, HashiCorp Vault, or environment variables (`Platform.environment`).',
      secureExample: r'final awsKey = Platform.environment["AWS_ACCESS_KEY_ID"];',
      cweOwasp: 'CWE-798 / OWASP M9: Insecure Data Storage',
    ),
    SecretPattern(
      id: 'SEC-002',
      title: 'Hardcoded AWS Secret Key',
      pattern: RegExp(r'''(aws_secret_access_key|aws_secret)\s*[:=]\s*["\'][0-9a-zA-Z\/+]{40}["\']''', caseSensitive: false),
      severity: Severity.critical,
      description: 'An AWS Secret Access Key was found in clear text.',
      remediation: 'Revoke the exposed key in the AWS IAM Console immediately. Inject keys at runtime via environment variables or secret store.',
      secureExample: r'final awsSecret = Platform.environment["AWS_SECRET_ACCESS_KEY"];',
      cweOwasp: 'CWE-798 / OWASP A07: Identification & Auth Failures',
    ),
    SecretPattern(
      id: 'SEC-003',
      title: 'Hardcoded Private Key Header',
      pattern: RegExp(r'''-----BEGIN (RSA|EC|DSA|OPENSSH|PRIVATE) KEY-----'''),
      severity: Severity.critical,
      description: 'A private cryptographic key block is hardcoded in clear text.',
      remediation: 'Never ship private keys in application binaries or repository code. Store them on secure backend servers or encrypted keystores.',
      secureExample: '// Private keys should be stored in platform Secure Keystore / Keyring',
      cweOwasp: 'CWE-321 / OWASP M9: Cryptographic Failures',
    ),
    SecretPattern(
      id: 'SEC-004',
      title: 'Hardcoded Generic API Token / Password',
      pattern: RegExp(r'''(api[_-]?key|secret[_-]?key|password|db_pass)\s*[:=]\s*["\'][^"\'\s]{8,}["\']''', caseSensitive: false),
      severity: Severity.high,
      description: 'Potential secret or API password assignment detected in code.',
      remediation: 'Store credentials in secure OS storage (`flutter_secure_storage` for mobile/desktop) or retrieve via an authenticated server handshake.',
      secureExample: r'const storage = FlutterSecureStorage();' '\n' r'final apiKey = await storage.read(key: "api_key");',
      cweOwasp: 'CWE-798 / OWASP Top 10 A07',
    ),
    SecretPattern(
      id: 'SEC-005',
      title: 'Hardcoded JWT Token',
      pattern: RegExp(r'''eyJ[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*'''),
      severity: Severity.high,
      description: 'A JSON Web Token (JWT) string is embedded in the binary or code.',
      remediation: 'Obtain JWT tokens dynamically via login APIs and store them in secure memory or encrypted local storage.',
      secureExample: '// Store access tokens transiently in secure memory or encrypted storage',
      cweOwasp: 'CWE-522 / OWASP M9: Insecure Storage',
    ),
    SecretPattern(
      id: 'SEC-006',
      title: 'Database Connection String with Credentials',
      pattern: RegExp(r'''(postgres|mysql|mongodb|redis|sqlserver):\/\/[^:]+:[^@]+@''', caseSensitive: false),
      severity: Severity.critical,
      description: 'Database connection URI contains plain text login credentials.',
      remediation: 'Do not connect directly to databases from client apps. Use an authenticated REST/GraphQL API layer or proxy.',
      secureExample: '// Connect to API backend instead of direct DB socket connection',
      cweOwasp: 'CWE-256 / OWASP A02: Cryptographic Failures',
    ),
  ];

  List<SecurityIssue> scan(String filePath, String content) {
    final List<SecurityIssue> issues = [];
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      for (final pattern in patterns) {
        if (pattern.pattern.hasMatch(line)) {
          if (filePath.contains('secret_scanner.dart')) continue;

          final matchedLine = line.trim();
          issues.add(
            SecurityIssue(
              id: '${pattern.id}_${i + 1}',
              title: pattern.title,
              description: pattern.description,
              category: IssueCategory.secrets,
              severity: pattern.severity,
              filePath: filePath,
              lineNumber: i + 1,
              snippet: matchedLine.length > 120 ? '${matchedLine.substring(0, 120)}...' : matchedLine,
              remediationAdvice: pattern.remediation,
              secureCodeExample: pattern.secureExample,
              cweOrOwasp: pattern.cweOwasp,
            ),
          );
        }
      }
    }

    return issues;
  }
}
