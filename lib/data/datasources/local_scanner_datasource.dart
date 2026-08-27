import 'dart:io';
import 'package:path/path.dart' as p;
import '../../domain/entities/security_issue.dart';
import '../../services/scanners/secret_scanner.dart';
import '../../services/scanners/manifest_scanner.dart';
import '../../services/scanners/code_quality_scanner.dart';

abstract class LocalScannerDataSource {
  Future<ScanResult> scanPath(
    String targetPath, {
    void Function(String currentFile, int scannedCount)? onProgress,
  });
}

class LocalScannerDataSourceImpl implements LocalScannerDataSource {
  final SecretScanner _secretScanner = SecretScanner();
  final ManifestScanner _manifestScanner = ManifestScanner();
  final CodeQualityScanner _codeQualityScanner = CodeQualityScanner();

  static const Set<String> _scannableExtensions = {
    // Flutter / Dart
    '.dart',
    // Android Native
    '.java', '.kt', '.xml', '.gradle', '.properties',
    // iOS Native
    '.swift', '.m', '.h', '.plist', '.pbxproj', '.xcconfig',
    // ASP.NET / C#
    '.cs', '.cshtml', '.razor', '.config', '.csproj', '.sln', '.props', '.targets',
    // Laravel / PHP
    '.php', '.phtml', '.htaccess', '.ini',
    // React Native / JS / TS
    '.js', '.jsx', '.ts', '.tsx',
    // Config / Data / Meta
    '.yaml', '.yml', '.json', '.env', '.txt', '.md',
  };

  static const Set<String> _ignoredDirectories = {
    '.git', '.dart_tool', '.idea', '.vscode', 'build', 'node_modules', 'pods', '.gradle',
    'bin', 'obj', '.vs', 'packages', 'testresults', 'vendor', 'coverage', 'dist'
  };

  @override
  Future<ScanResult> scanPath(
    String targetPath, {
    void Function(String currentFile, int scannedCount)? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();
    final List<SecurityIssue> allIssues = [];
    int fileCount = 0;

    final targetEntity = FileSystemEntity.typeSync(targetPath);

    if (targetEntity == FileSystemEntityType.file) {
      final file = File(targetPath);
      await _scanSingleFile(file, allIssues);
      fileCount = 1;
      onProgress?.call(file.path, 1);
    } else if (targetEntity == FileSystemEntityType.directory) {
      final dir = Directory(targetPath);
      final List<FileSystemEntity> entities = dir.listSync(recursive: true, followLinks: false);

      for (final entity in entities) {
        if (entity is File) {
          final relativePath = p.relative(entity.path, from: targetPath);
          final pathSegments = p.split(relativePath);

          if (pathSegments.any((part) => _ignoredDirectories.contains(part.toLowerCase()))) {
            continue;
          }

          final ext = p.extension(entity.path).toLowerCase();
          final fileName = p.basename(entity.path).toLowerCase();

          if (_scannableExtensions.contains(ext) ||
              fileName.endsWith('.blade.php') ||
              fileName.startsWith('.env') ||
              fileName == 'androidmanifest.xml' ||
              fileName == 'info.plist' ||
              fileName == 'web.config' ||
              fileName == 'php.ini' ||
              fileName == 'composer.json' ||
              fileName == 'package.json' ||
              fileName.startsWith('appsettings')) {
            fileCount++;
            onProgress?.call(entity.path, fileCount);
            await _scanSingleFile(entity, allIssues);
          }
        }
      }
    }

    stopwatch.stop();

    return ScanResult(
      targetPath: targetPath,
      scanTime: DateTime.now(),
      issues: allIssues,
      totalFilesScanned: fileCount,
      scanDuration: stopwatch.elapsed,
    );
  }

  Future<void> _scanSingleFile(File file, List<SecurityIssue> issues) async {
    try {
      final length = await file.length();
      if (length > 5 * 1024 * 1024) return;

      final content = await file.readAsString();

      issues.addAll(_secretScanner.scan(file.path, content));
      issues.addAll(_manifestScanner.scan(file.path, content));
      issues.addAll(_codeQualityScanner.scan(file.path, content));
    } catch (_) {
      // Ignore unreadable binary errors
    }
  }
}
