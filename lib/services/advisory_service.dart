import '../domain/entities/security_issue.dart';

class AdvisoryService {
  static final List<SecurityGuideline> hardeningGuides = [
    const SecurityGuideline(
      title: 'Laravel & PHP Security Hardening',
      category: 'Web & Backend Security',
      platform: 'Laravel / PHP 8.x',
      summary: 'Protect PHP and Laravel web applications against SQL Injection, RCE, LFI, XSS, and dangerous object unserialization.',
      checklist: [
        'Set `APP_DEBUG=false` in production `.env` to avoid exposing stack trace error pages.',
        'Run `php artisan key:generate` to ensure a cryptographically secure `APP_KEY`.',
        'Use PDO prepared statements or Eloquent parameterized bindings instead of `DB::raw()`.',
        'Never call `unserialize()` on user input. Use `json_decode()`.',
        'Escape HTML outputs in PHP templates using `htmlspecialchars(\$input, ENT_QUOTES, "UTF-8")`.',
      ],
      codeSnippet: r'''
// Laravel Parameterized Query & Hardened Route Example
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;

public function searchUsers(Request $request)
{
    $email = $request->input('email');
    
    // Secure Parameterized Query
    $users = DB::select("SELECT id, name, email FROM users WHERE email = ?", [$email]);
    
    return response()->json($users);
}''',
    ),
    const SecurityGuideline(
      title: 'React Native Security Hardening',
      category: 'Mobile Security',
      platform: 'React Native / Expo',
      summary: 'Harden React Native applications against insecure data storage, API key bundling, and XSS risks.',
      checklist: [
        'Never store auth tokens or private keys in `AsyncStorage`. Use `react-native-keychain` or `expo-secure-store`.',
        'Avoid `dangerouslySetInnerHTML` and `eval()`. Use HTML sanitizers like `DOMPurify`.',
        'Enforce HTTPS/WSS for all network and WebSocket connections.',
        'Obfuscate JavaScript bundles in release builds using Hermes engine or ProGuard/DexGuard.',
      ],
      codeSnippet: '''
import * as Keychain from 'react-native-keychain';

// Secure Token Storage using iOS Keychain & Android Keystore
export const storeAuthToken = async (token: string) => {
  await Keychain.setGenericPassword('auth_session', token, {
    service: 'app_auth_token',
    accessible: Keychain.ACCESSIBLE.WHEN_UNLOCKED,
  });
};

export const getAuthToken = async () => {
  const credentials = await Keychain.getGenericPassword({ service: 'app_auth_token' });
  return credentials ? credentials.password : null;
};''',
    ),
    const SecurityGuideline(
      title: 'ASP.NET Core & .NET Web Hardening',
      category: 'Web & Backend Security',
      platform: 'ASP.NET Core / .NET 6/7/8',
      summary: 'Harden ASP.NET Web APIs and Razor Pages against SQL Injection, CSRF, insecure deserialization, and web.config leaks.',
      checklist: [
        'Use `FromSqlInterpolated` or EF Core LINQ queries instead of string-concatenated raw SQL.',
        'Never use `BinaryFormatter` or `NetDataContractSerializer`. Use `System.Text.Json`.',
        'Set `debug="false"` and `customErrors mode="RemoteOnly"` in production `web.config`.',
        'Enforce `[ValidateAntiForgeryToken]` on state-altering HTTP POST/PUT actions.',
        'Configure explicit CORS policies (`WithOrigins("https://...")`) instead of `AllowAnyOrigin()`.',
      ],
      codeSnippet: '''
// Program.cs - ASP.NET Core Security Configuration
var builder = WebApplication.CreateBuilder(args);

// Enforce Antiforgery & Strict CORS
builder.Services.AddAntiforgery(options => options.HeaderName = "X-XSRF-TOKEN");
builder.Services.AddCors(options => {
    options.AddPolicy("ProductionCors", policy =>
        policy.WithOrigins("https://app.bflabs.io")
              .WithMethods("GET", "POST", "PUT")
              .WithHeaders("Content-Type", "Authorization"));
});

var app = builder.Build();

if (!app.Environment.IsDevelopment()) {
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseCors("ProductionCors");
app.UseAuthentication();
app.UseAuthorization();''',
    ),
    const SecurityGuideline(
      title: 'Secure Key & Token Storage (Flutter)',
      category: 'Data Protection',
      platform: 'Flutter / Cross-Platform',
      summary: 'Never store plain-text auth tokens, API keys, or private user data in SharedPreferences or LocalStorage.',
      checklist: [
        'Use Encrypted Keystore (Android) / Keychain (iOS) via `flutter_secure_storage`.',
        'Enable biometric protection for accessing highly sensitive keys.',
        'Clear tokens upon logout or session timeout.',
      ],
      codeSnippet: '''
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureVault {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(
      key: 'auth_token', 
      value: token,
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}''',
    ),
    const SecurityGuideline(
      title: 'Android Manifest & App Hardening',
      category: 'Platform Security',
      platform: 'Android Native',
      summary: 'Harden application runtime configuration to prevent unauthorized inter-app inspection and data theft.',
      checklist: [
        'Set `android:allowBackup="false"` in `<application>`.',
        'Set `android:usesCleartextTraffic="false"`.',
        'Ensure exported components explicitly define access permissions.',
        'Enable ProGuard / R8 code obfuscation in release builds.',
      ],
      codeSnippet: '''
<!-- AndroidManifest.xml Hardening Example -->
<application
    android:allowBackup="false"
    android:usesCleartextTraffic="false"
    android:supportsRtl="true"
    android:theme="@style/AppTheme">
    
    <activity
        android:name=".MainActivity"
        android:exported="false" />
</application>''',
    ),
    const SecurityGuideline(
      title: 'iOS App Transport Security (ATS) & Keychain',
      category: 'Platform Security',
      platform: 'iOS Native',
      summary: 'Ensure App Transport Security policies enforce TLS 1.2+ with forward secrecy and secure Keychain accessibility.',
      checklist: [
        'Do NOT set `NSAllowsArbitraryLoads = true`.',
        'Declare explicit domain exceptions if non-conforming hosts are strictly required.',
        'Store all auth tokens using iOS Keychain Services instead of `UserDefaults`.',
      ],
      codeSnippet: '''
<!-- Info.plist Configuration -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>''',
    ),
  ];
}
