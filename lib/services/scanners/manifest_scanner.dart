import '../../domain/entities/security_issue.dart';

class ManifestScanner {
  List<SecurityIssue> scan(String filePath, String content) {
    if (filePath.contains('manifest_scanner.dart')) return [];
    final List<SecurityIssue> issues = [];
    final fileName = filePath.split(RegExp(r'[/\\]')).last.toLowerCase();

    if (fileName == 'androidmanifest.xml') {
      _scanAndroidManifest(filePath, content, issues);
    } else if (fileName == 'info.plist') {
      _scanInfoPlist(filePath, content, issues);
    } else if (fileName == 'network_security_config.xml') {
      _scanNetworkConfig(filePath, content, issues);
    } else if (fileName == 'pubspec.yaml' || fileName == 'package.json') {
      _scanDependencyConfigs(filePath, content, issues);
    } else if (fileName == 'web.config') {
      _scanWebConfig(filePath, content, issues);
    } else if (fileName.startsWith('appsettings') && fileName.endsWith('.json')) {
      _scanAppSettingsJson(filePath, content, issues);
    } else if (fileName.startsWith('.env')) {
      _scanEnvFile(filePath, content, issues);
    } else if (fileName == 'php.ini') {
      _scanPhpIni(filePath, content, issues);
    }

    return issues;
  }

  void _scanAndroidManifest(String filePath, String content, List<SecurityIssue> issues) {
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.contains('android:debuggable="true"')) {
        issues.add(
          SecurityIssue(
            id: 'MAN-001_${i + 1}',
            title: 'Android Debuggable Flag Enabled',
            description: 'The application explicitly sets `android:debuggable="true"` in the Android Manifest.',
            category: IssueCategory.manifestConfig,
            severity: Severity.critical,
            filePath: filePath,
            lineNumber: i + 1,
            snippet: line.trim(),
            remediationAdvice: 'Set `android:debuggable="false"` or omit this attribute in production builds.',
            secureCodeExample: '<application\n    android:debuggable="false"\n    ... >',
            cweOrOwasp: 'CWE-215 / OWASP M8: Code Tampering',
          ),
        );
      }

      if (line.contains('android:usesCleartextTraffic="true"')) {
        issues.add(
          SecurityIssue(
            id: 'MAN-002_${i + 1}',
            title: 'Cleartext HTTP Traffic Allowed (Android)',
            description: '`android:usesCleartextTraffic="true"` allows unencrypted HTTP connections across the application.',
            category: IssueCategory.networkSecurity,
            severity: Severity.high,
            filePath: filePath,
            lineNumber: i + 1,
            snippet: line.trim(),
            remediationAdvice: 'Enforce HTTPS for all network requests. Set `android:usesCleartextTraffic="false"`.',
            secureCodeExample: '<application\n    android:usesCleartextTraffic="false"\n    ... >',
            cweOrOwasp: 'CWE-319 / OWASP M3: Insecure Communication',
          ),
        );
      }

      if (line.contains('android:allowBackup="true"')) {
        issues.add(
          SecurityIssue(
            id: 'MAN-003_${i + 1}',
            title: 'Application Backup Allowed (Android)',
            description: '`android:allowBackup="true"` allows application data to be extracted via `adb backup`.',
            category: IssueCategory.manifestConfig,
            severity: Severity.medium,
            filePath: filePath,
            lineNumber: i + 1,
            snippet: line.trim(),
            remediationAdvice: 'Disable application backup unless encrypted backup rules are explicitly implemented.',
            secureCodeExample: '<application\n    android:allowBackup="false"\n    ... >',
            cweOrOwasp: 'CWE-530 / OWASP M9: Insecure Storage',
          ),
        );
      }

      if (line.contains('android:exported="true"')) {
        issues.add(
          SecurityIssue(
            id: 'MAN-004_${i + 1}',
            title: 'Exported Android Component',
            description: 'An activity, service, or receiver is exported (`android:exported="true"`), making it accessible to third-party apps.',
            category: IssueCategory.permissions,
            severity: Severity.medium,
            filePath: filePath,
            lineNumber: i + 1,
            snippet: line.trim(),
            remediationAdvice: 'Verify whether this component needs to be exported. Set `android:exported="false"` if internal.',
            secureCodeExample: '<activity\n    android:name=".InternalActivity"\n    android:exported="false" />',
            cweOrOwasp: 'CWE-926 / OWASP M1: Improper Platform Usage',
          ),
        );
      }
    }
  }

  void _scanInfoPlist(String filePath, String content, List<SecurityIssue> issues) {
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.contains('<key>NSAllowsArbitraryLoads</key>') || (line.contains('NSAllowsArbitraryLoads') && lines.length > i + 1 && lines[i + 1].contains('<true/>'))) {
        issues.add(
          SecurityIssue(
            id: 'IOS-001_${i + 1}',
            title: 'iOS Arbitrary Network Loads Allowed',
            description: '`NSAllowsArbitraryLoads` disables App Transport Security (ATS) restrictions, enabling HTTP traffic.',
            category: IssueCategory.networkSecurity,
            severity: Severity.high,
            filePath: filePath,
            lineNumber: i + 1,
            snippet: line.trim(),
            remediationAdvice: 'Remove `NSAllowsArbitraryLoads` or specify domain-specific exceptions for trusted HTTP endpoints only.',
            secureCodeExample: '<key>NSAppTransportSecurity</key>\n<dict>\n    <key>NSAllowsArbitraryLoads</key>\n    <false/>\n</dict>',
            cweOrOwasp: 'CWE-319 / OWASP M3: Insecure Communication',
          ),
        );
      }
    }
  }

  void _scanNetworkConfig(String filePath, String content, List<SecurityIssue> issues) {
    if (content.contains('cleartextTrafficPermitted="true"')) {
      issues.add(
        SecurityIssue(
          id: 'NET-001',
          title: 'Network Security Config Permitting Cleartext',
          description: 'Network Security Config explicitly permits cleartext traffic for domains.',
          category: IssueCategory.networkSecurity,
          severity: Severity.high,
          filePath: filePath,
          lineNumber: 1,
          snippet: 'cleartextTrafficPermitted="true"',
          remediationAdvice: 'Enforce HTTPS everywhere. Set `cleartextTrafficPermitted="false"`.',
          secureCodeExample: '<domain-config cleartextTrafficPermitted="false">',
          cweOrOwasp: 'CWE-319 / OWASP M3',
        ),
      );
    }
  }

  void _scanDependencyConfigs(String filePath, String content, List<SecurityIssue> issues) {
    if (content.contains('http://') && !content.contains('http://localhost') && !content.contains('http://127.0.0.1')) {
      issues.add(
        SecurityIssue(
          id: 'DEP-001',
          title: 'Insecure HTTP Dependency URL',
          description: 'A dependency or repository source is fetched over unencrypted HTTP.',
          category: IssueCategory.bestPractices,
          severity: Severity.medium,
          filePath: filePath,
          lineNumber: 1,
          snippet: 'http:// URL in dependency configuration file',
          remediationAdvice: 'Always use HTTPS repository URLs to prevent Man-in-the-Middle package tampering.',
          secureCodeExample: 'url: https://pub.dev',
          cweOrOwasp: 'CWE-494 / OWASP A08: Software and Data Integrity Failures',
        ),
      );
    }
  }

  void _scanWebConfig(String filePath, String content, List<SecurityIssue> issues) {
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.contains('debug="true"') && line.contains('<compilation')) {
        issues.add(
          SecurityIssue(
            id: 'NET-MAN-001_${i + 1}',
            title: 'ASP.NET web.config Compilation Debug Mode Enabled',
            description: '`debug="true"` is enabled in web.config `<compilation>`. Exposes source code symbols and diagnostic handlers.',
            category: IssueCategory.manifestConfig,
            severity: Severity.critical,
            filePath: filePath,
            lineNumber: i + 1,
            snippet: line.trim(),
            remediationAdvice: 'Set `debug="false"` in production web.config.',
            secureCodeExample: '<system.web>\n  <compilation debug="false" targetFramework="4.8" />\n</system.web>',
            cweOrOwasp: 'CWE-215 / OWASP A05: Security Misconfiguration',
          ),
        );
      }

      if (line.contains('mode="Off"') && line.contains('<customErrors')) {
        issues.add(
          SecurityIssue(
            id: 'NET-MAN-002_${i + 1}',
            title: 'ASP.NET Detailed Error Pages Exposed (customErrors="Off")',
            description: '`customErrors mode="Off"` displays full stack traces and sensitive error details upon exceptions.',
            category: IssueCategory.manifestConfig,
            severity: Severity.high,
            filePath: filePath,
            lineNumber: i + 1,
            snippet: line.trim(),
            remediationAdvice: 'Set `mode="RemoteOnly"` or `mode="On"`.',
            secureCodeExample: '<system.web>\n  <customErrors mode="RemoteOnly" defaultRedirect="~/Error.html" />\n</system.web>',
            cweOrOwasp: 'CWE-209 / OWASP A05: Security Misconfiguration',
          ),
        );
      }
    }
  }

  void _scanAppSettingsJson(String filePath, String content, List<SecurityIssue> issues) {
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if ((line.contains('"Password"') || line.contains('"User Id"') || line.contains('"pwd"')) &&
          (line.contains('Server=') || line.contains('Database=') || line.contains('Data Source='))) {
        issues.add(
          SecurityIssue(
            id: 'NET-CFG-001_${i + 1}',
            title: 'Hardcoded Database Credentials in appsettings.json',
            description: 'Hardcoded SQL Server or Database connection string with cleartext credentials found in appsettings.',
            category: IssueCategory.secrets,
            severity: Severity.critical,
            filePath: filePath,
            lineNumber: i + 1,
            snippet: line.trim(),
            remediationAdvice: 'Inject connection strings via Azure Key Vault or Environment Variables.',
            secureCodeExample: r'"ConnectionStrings": { "DefaultConnection": "Server=...;Database=...;Integrated Security=True;" }',
            cweOrOwasp: 'CWE-798 / OWASP A07',
          ),
        );
      }
    }
  }

  void _scanEnvFile(String filePath, String content, List<SecurityIssue> issues) {
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().startsWith('APP_DEBUG=true')) {
        issues.add(
          SecurityIssue(
            id: 'LAR-ENV-001_${i + 1}',
            title: 'Laravel APP_DEBUG Enabled in Environment Configuration',
            description: '`APP_DEBUG=true` in Laravel displays detailed stack traces, database queries, and environment secrets to web visitors upon errors.',
            category: IssueCategory.manifestConfig,
            severity: Severity.critical,
            filePath: filePath,
            lineNumber: i + 1,
            snippet: line.trim(),
            remediationAdvice: 'Set `APP_DEBUG=false` in production `.env` files.',
            secureCodeExample: 'APP_ENV=production\nAPP_DEBUG=false',
            cweOrOwasp: 'CWE-215 / OWASP A05: Security Misconfiguration',
          ),
        );
      }

      if (line.trim().startsWith('APP_KEY=') && (line.trim() == 'APP_KEY=' || line.trim() == 'APP_KEY=SomeRandomString')) {
        issues.add(
          SecurityIssue(
            id: 'LAR-ENV-002_${i + 1}',
            title: 'Laravel Missing or Default Application Key (APP_KEY)',
            description: '`APP_KEY` is missing or set to default value. Encryption, session cookies, and hashed data will be insecure.',
            category: IssueCategory.manifestConfig,
            severity: Severity.critical,
            filePath: filePath,
            lineNumber: i + 1,
            snippet: line.trim(),
            remediationAdvice: 'Run `php artisan key:generate` to generate a cryptographically secure application key.',
            secureCodeExample: 'APP_KEY=base64:GeneratedSecureKeyHere...',
            cweOrOwasp: 'CWE-321 / OWASP A02: Cryptographic Failures',
          ),
        );
      }
    }
  }

  void _scanPhpIni(String filePath, String content, List<SecurityIssue> issues) {
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.contains('display_errors = On') || line.contains('display_errors=On')) {
        issues.add(
          SecurityIssue(
            id: 'PHP-INI-001_${i + 1}',
            title: 'PHP display_errors Enabled in php.ini',
            description: '`display_errors = On` outputs PHP runtime warnings and fatal exception details directly into HTML web pages.',
            category: IssueCategory.manifestConfig,
            severity: Severity.high,
            filePath: filePath,
            lineNumber: i + 1,
            snippet: line.trim(),
            remediationAdvice: 'Set `display_errors = Off` and log errors to file via `log_errors = On`.',
            secureCodeExample: 'display_errors = Off\nlog_errors = On',
            cweOrOwasp: 'CWE-209 / OWASP A05: Security Misconfiguration',
          ),
        );
      }

      if (line.contains('allow_url_include = On') || line.contains('allow_url_include=On')) {
        issues.add(
          SecurityIssue(
            id: 'PHP-INI-002_${i + 1}',
            title: 'PHP allow_url_include Enabled (Remote File Inclusion Risk)',
            description: '`allow_url_include = On` allows remote HTTP URLs to be loaded in `include()` or `require()`, leading to Remote Code Execution.',
            category: IssueCategory.manifestConfig,
            severity: Severity.critical,
            filePath: filePath,
            lineNumber: i + 1,
            snippet: line.trim(),
            remediationAdvice: 'Set `allow_url_include = Off` in php.ini immediately.',
            secureCodeExample: 'allow_url_include = Off',
            cweOrOwasp: 'CWE-98 / OWASP A03: Injection',
          ),
        );
      }
    }
  }
}
