import 'package:equatable/equatable.dart';

enum Severity { critical, high, medium, low, info }

enum IssueCategory { secrets, manifestConfig, networkSecurity, permissions, crypto, codeQuality, bestPractices }

class SecurityIssue extends Equatable {
  final String id;
  final String title;
  final String description;
  final IssueCategory category;
  final Severity severity;
  final String filePath;
  final int lineNumber;
  final String snippet;
  final String remediationAdvice;
  final String secureCodeExample;
  final String cweOrOwasp;

  const SecurityIssue({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.filePath,
    required this.lineNumber,
    required this.snippet,
    required this.remediationAdvice,
    required this.secureCodeExample,
    required this.cweOrOwasp,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        severity,
        filePath,
        lineNumber,
        snippet,
        remediationAdvice,
        secureCodeExample,
        cweOrOwasp,
      ];
}

class ScanResult extends Equatable {
  final String targetPath;
  final DateTime scanTime;
  final List<SecurityIssue> issues;
  final int totalFilesScanned;
  final Duration scanDuration;

  const ScanResult({
    required this.targetPath,
    required this.scanTime,
    required this.issues,
    required this.totalFilesScanned,
    required this.scanDuration,
  });

  int get criticalCount => issues.where((i) => i.severity == Severity.critical).length;
  int get highCount => issues.where((i) => i.severity == Severity.high).length;
  int get mediumCount => issues.where((i) => i.severity == Severity.medium).length;
  int get lowCount => issues.where((i) => i.severity == Severity.low).length;
  int get infoCount => issues.where((i) => i.severity == Severity.info).length;

  int get securityScore {
    if (totalFilesScanned == 0) return 100;
    int penalty = (criticalCount * 25) + (highCount * 15) + (mediumCount * 8) + (lowCount * 3);
    int score = 100 - penalty;
    return score < 0 ? 0 : score;
  }

  @override
  List<Object?> get props => [
        targetPath,
        scanTime,
        issues,
        totalFilesScanned,
        scanDuration,
      ];
}

class SecurityGuideline extends Equatable {
  final String title;
  final String category;
  final String platform;
  final String summary;
  final List<String> checklist;
  final String codeSnippet;

  const SecurityGuideline({
    required this.title,
    required this.category,
    required this.platform,
    required this.summary,
    required this.checklist,
    required this.codeSnippet,
  });

  @override
  List<Object?> get props => [
        title,
        category,
        platform,
        summary,
        checklist,
        codeSnippet,
      ];
}
