import '../../domain/entities/security_issue.dart';

class CodeQualityPattern {
  final String id;
  final String title;
  final RegExp pattern;
  final Severity severity;
  final IssueCategory category;
  final String description;
  final String remediation;
  final String secureExample;
  final String cweOrOwasp;

  CodeQualityPattern({
    required this.id,
    required this.title,
    required this.pattern,
    required this.severity,
    required this.category,
    required this.description,
    required this.remediation,
    required this.secureExample,
    required this.cweOrOwasp,
  });
}

class CodeQualityScanner {
  final List<CodeQualityPattern> patterns = [
    // --- 1. Cross-Platform / Cryptography ---
    CodeQualityPattern(
      id: 'CRY-001',
      title: 'Weak Hashing Algorithm (MD5 / SHA-1)',
      pattern: RegExp(r'(md5|sha1)\.convert|MessageDigest|MD5CryptoServiceProvider|SHA1CryptoServiceProvider|MD5\.Create|SHA1\.Create|md5\(|sha1\(', caseSensitive: false),
      severity: Severity.high,
      category: IssueCategory.crypto,
      description: 'MD5 and SHA-1 are cryptographically broken algorithms vulnerable to collision attacks.',
      remediation: 'Use SHA-256 or SHA-512 for data integrity checks, and bcrypt / Argon2id / PBKDF2 for password hashing.',
      secureExample: r'using var sha256 = SHA256.Create();' '\n' r'var hash = sha256.ComputeHash(bytes);',
      cweOrOwasp: 'CWE-327 / OWASP A02: Cryptographic Failures',
    ),
    CodeQualityPattern(
      id: 'CRY-002',
      title: 'Insecure ECB Cipher Mode',
      pattern: RegExp(r'Cipher\.getInstance.*ECB|CipherMode\.ECB', caseSensitive: false),
      severity: Severity.critical,
      category: IssueCategory.crypto,
      description: 'Electronic Codebook (ECB) mode does not use an Initialization Vector (IV), exposing identical plaintext blocks.',
      remediation: 'Use Cipher Block Chaining (CBC) with a randomized IV or Galois/Counter Mode (GCM).',
      secureExample: 'aes.Mode = CipherMode.CBC;\naes.GenerateIV();',
      cweOrOwasp: 'CWE-327 / OWASP A02: Cryptographic Failures',
    ),
    CodeQualityPattern(
      id: 'RNG-001',
      title: 'Weak Pseudorandom Number Generator',
      pattern: RegExp(r'Random\(\)\.next|Math\.random\(\)|java\.util\.Random|new\s+Random\(\)|rand\(|mt_rand\('),
      severity: Severity.medium,
      category: IssueCategory.crypto,
      description: 'Non-cryptographic pseudorandom generators produce predictable output patterns.',
      remediation: 'Use secure random generators (`RandomNumberGenerator`, `Random.secure()`, `random_bytes()`).',
      secureExample: r'var bytes = random_bytes(32);',
      cweOrOwasp: 'CWE-338 / OWASP A02: Cryptographic Failures',
    ),

    // --- 2. Laravel & PHP Security Patterns ---
    CodeQualityPattern(
      id: 'PHP-SQL-001',
      title: 'PHP / Laravel Potential SQL Injection',
      pattern: RegExp(r'DB::raw\(.*\$|mysql_query\(.*\$|mysqli_query\(.*\$|\$db->query\(.*\$|\$pdo->query\(.*\$', caseSensitive: false),
      severity: Severity.critical,
      category: IssueCategory.codeQuality,
      description: r'Concatenating unescaped variables directly into raw SQL queries allows SQL Injection attacks.',
      remediation: r'Use PDO prepared statements ($stmt->prepare()) or Laravel Eloquent parameterized bindings (DB::select("...", [$param])).',
      secureExample: r'$users = DB::select("SELECT * FROM users WHERE email = ?", [$email]);',
      cweOrOwasp: 'CWE-89 / OWASP A03: Injection',
    ),
    CodeQualityPattern(
      id: 'PHP-RCE-001',
      title: 'PHP Command Execution / Code Injection Vulnerability',
      pattern: RegExp(r'\b(eval|exec|passthru|shell_exec|system)\s*\(\s*\$'),
      severity: Severity.critical,
      category: IssueCategory.codeQuality,
      description: 'Executing system shell commands or evaluating C-like code with dynamic user input leads to Remote Code Execution (RCE).',
      remediation: r'Avoid system shell execution. Use specialized PHP libraries or sanitize arguments using escapeshellarg().',
      secureExample: r'$cleanArg = escapeshellarg($userInput);' '\n' r'exec("ls " . $cleanArg);',
      cweOrOwasp: 'CWE-78 / OWASP A03: Injection',
    ),
    CodeQualityPattern(
      id: 'PHP-LFI-001',
      title: 'PHP Local File Inclusion (LFI) Vulnerability',
      pattern: RegExp(r'\b(include|require|include_once|require_once)\s*\(\s*\$_(GET|POST|REQUEST)'),
      severity: Severity.critical,
      category: IssueCategory.codeQuality,
      description: 'Including file paths controlled directly by user request parameters allows Local / Remote File Inclusion.',
      remediation: 'Use an explicit whitelist array of allowed page identifiers instead of dynamic file paths.',
      secureExample: r'$allowed = ["home" => "home.php", "about" => "about.php"];' '\n' r'include $allowed[$page];',
      cweOrOwasp: 'CWE-98 / OWASP A03: Injection',
    ),
    CodeQualityPattern(
      id: 'PHP-XSS-001',
      title: 'PHP Unescaped Output / XSS Vulnerability',
      pattern: RegExp(r'echo\s+\$_(GET|POST|REQUEST)|{\!\!\s*\$_(GET|POST|REQUEST).*\!\!}'),
      severity: Severity.high,
      category: IssueCategory.codeQuality,
      description: 'Echoing unescaped user inputs directly into HTML responses allows Cross-Site Scripting (XSS).',
      remediation: r'Escape HTML output using htmlspecialchars($input, ENT_QUOTES, "UTF-8") or standard Blade {{ $var }} escaping.',
      secureExample: r'echo htmlspecialchars($_GET["user"], ENT_QUOTES, "UTF-8");',
      cweOrOwasp: 'CWE-79 / OWASP A03: Injection',
    ),
    CodeQualityPattern(
      id: 'LAR-SER-001',
      title: 'PHP Insecure Object Unserialization',
      pattern: RegExp(r'\bunserialize\s*\(\s*\$_(GET|POST|REQUEST|\w+)'),
      severity: Severity.critical,
      category: IssueCategory.codeQuality,
      description: r'Calling unserialize() on untrusted input allows PHP Object Injection and arbitrary code execution.',
      remediation: r'Use json_decode() and json_encode() for data serialization.',
      secureExample: r'$data = json_decode($jsonString, true);',
      cweOrOwasp: 'CWE-502 / OWASP A08',
    ),

    // --- 3. React Native & JavaScript / TypeScript Security Patterns ---
    CodeQualityPattern(
      id: 'RN-STO-001',
      title: 'React Native Insecure Storage (AsyncStorage for Sensitive Data)',
      pattern: RegExp(r'AsyncStorage\.setItem\(.*(token|auth|password|secret|key)', caseSensitive: false),
      severity: Severity.high,
      category: IssueCategory.codeQuality,
      description: '`AsyncStorage` stores data unencrypted in plain text on iOS and Android file systems.',
      remediation: 'Use `react-native-keychain` or `expo-secure-store` for storing sensitive auth tokens and keys.',
      secureExample: r'await Keychain.setGenericPassword("user", token);',
      cweOrOwasp: 'CWE-922 / OWASP M9: Insecure Storage',
    ),
    CodeQualityPattern(
      id: 'JS-XSS-001',
      title: 'React / React Native Dangerous HTML Rendering',
      pattern: RegExp(r'dangerouslySetInnerHTML|eval\s*\('),
      severity: Severity.high,
      category: IssueCategory.codeQuality,
      description: 'Using `dangerouslySetInnerHTML` or `eval()` allows Cross-Site Scripting (XSS) and code injection.',
      remediation: 'Sanitize HTML content using `DOMPurify` before rendering.',
      secureExample: r'const cleanHtml = DOMPurify.sanitize(dirtyHtml);',
      cweOrOwasp: 'CWE-79 / OWASP A03: Injection',
    ),

    // --- 4. ASP.NET & C# Security Patterns ---
    CodeQualityPattern(
      id: 'NET-SQL-001',
      title: '.NET Potential SQL Injection via String Interpolation',
      pattern: RegExp(r'FromSqlRaw\(.*\$"|ExecuteSqlRaw\(.*\$"|FromSql\(\$"|ExecuteSqlCommand\(.*\$"', caseSensitive: false),
      severity: Severity.critical,
      category: IssueCategory.codeQuality,
      description: r'Executing raw SQL queries using interpolated strings (`FromSqlRaw($"SELECT ... {userInput}")`) allows SQL Injection attacks.',
      remediation: r'Use `FromSqlInterpolated($"SELECT * FROM Users WHERE Email = {email}")` or parameterized SQL parameters.',
      secureExample: r'context.Users.FromSqlInterpolated($"SELECT * FROM Users WHERE Email = {email}");',
      cweOrOwasp: 'CWE-89 / OWASP A03: Injection',
    ),
    CodeQualityPattern(
      id: 'NET-SER-001',
      title: '.NET Insecure Object Deserialization (BinaryFormatter)',
      pattern: RegExp(r'BinaryFormatter|NetDataContractSerializer|ObjectStateFormatter', caseSensitive: false),
      severity: Severity.critical,
      category: IssueCategory.codeQuality,
      description: '`BinaryFormatter` is inherently dangerous and vulnerable to Remote Code Execution (RCE) attacks during deserialization.',
      remediation: 'Migrate to `System.Text.Json` or `Newtonsoft.Json` with explicit type safety controls.',
      secureExample: r'var data = JsonSerializer.Deserialize<MyModel>(jsonString);',
      cweOrOwasp: 'CWE-502 / OWASP A08',
    ),
    CodeQualityPattern(
      id: 'NET-CORS-001',
      title: 'ASP.NET Core Overly Permissive CORS Policy',
      pattern: RegExp(r'AllowAnyOrigin\(\)\.AllowAnyHeader\(\)\.AllowAnyMethod\(\)', caseSensitive: false),
      severity: Severity.high,
      category: IssueCategory.bestPractices,
      description: 'Configuring `AllowAnyOrigin()` along with unrestricted methods permits any web domain to send cross-origin requests.',
      remediation: 'Specify explicit trusted origins using `WithOrigins("https://yourdomain.com")`.',
      secureExample: r'options.AddPolicy("StrictCors", builder => builder.WithOrigins("https://app.bflabs.io").WithMethods("GET", "POST"));',
      cweOrOwasp: 'CWE-942 / OWASP A05',
    ),

    // --- 5. Android Native (Kotlin / Java) Security Patterns ---
    CodeQualityPattern(
      id: 'AND-STO-001',
      title: 'Android Insecure Storage via Unencrypted SharedPreferences',
      pattern: RegExp(r'getSharedPreferences\(.*\.edit\(\).*(putString|putStringSet).*token|password|auth', caseSensitive: false),
      severity: Severity.medium,
      category: IssueCategory.codeQuality,
      description: 'Saving auth tokens in plain-text SharedPreferences XML files allows data extraction on rooted devices.',
      remediation: 'Use `EncryptedSharedPreferences` from Android Jetpack Security (`androidx.security.crypto`).',
      secureExample: r'val sharedPreferences = EncryptedSharedPreferences.create(...)',
      cweOrOwasp: 'CWE-922 / OWASP M9: Insecure Storage',
    ),
    CodeQualityPattern(
      id: 'AND-WEB-001',
      title: 'Android Insecure WebView File Access Configuration',
      pattern: RegExp(r'setAllowFileAccess\(true\)|setAllowContentAccess\(true\)', caseSensitive: false),
      severity: Severity.high,
      category: IssueCategory.codeQuality,
      description: 'Enabling file access in WebViews allows malicious scripts inside the WebView to access local app files.',
      remediation: 'Set `setAllowFileAccess(false)` unless local file access is strictly required.',
      secureExample: r'webView.settings.allowFileAccess = false',
      cweOrOwasp: 'CWE-94 / OWASP M1',
    ),

    // --- 6. iOS Native (Swift / Objective-C) Security Patterns ---
    CodeQualityPattern(
      id: 'IOS-STO-001',
      title: 'iOS Insecure Storage via Plain Text UserDefaults',
      pattern: RegExp(r'UserDefaults\.standard\.set\(.*(token|password|auth|secret)', caseSensitive: false),
      severity: Severity.medium,
      category: IssueCategory.codeQuality,
      description: '`UserDefaults` stores data unencrypted in plain-text plist files.',
      remediation: 'Store sensitive authentication tokens in iOS Keychain Services using `SecItemAdd`.',
      secureExample: r'let status = SecItemAdd(query as CFDictionary, nil)',
      cweOrOwasp: 'CWE-922 / OWASP M9',
    ),
  ];

  List<SecurityIssue> scan(String filePath, String content) {
    final List<SecurityIssue> issues = [];
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      for (final pattern in patterns) {
        if (pattern.pattern.hasMatch(line)) {
          if (filePath.contains('code_quality_scanner.dart')) continue;

          final matchedLine = line.trim();
          issues.add(
            SecurityIssue(
              id: '${pattern.id}_${i + 1}',
              title: pattern.title,
              description: pattern.description,
              category: pattern.category,
              severity: pattern.severity,
              filePath: filePath,
              lineNumber: i + 1,
              snippet: matchedLine.length > 120 ? '${matchedLine.substring(0, 120)}...' : matchedLine,
              remediationAdvice: pattern.remediation,
              secureCodeExample: pattern.secureExample,
              cweOrOwasp: pattern.cweOrOwasp,
            ),
          );
        }
      }
    }

    return issues;
  }
}
