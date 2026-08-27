import 'package:equatable/equatable.dart';
import '../../../domain/entities/security_issue.dart';

abstract class AuditState extends Equatable {
  const AuditState();

  @override
  List<Object?> get props => [];
}

class AuditInitialState extends AuditState {}

class AuditScanningState extends AuditState {
  final String currentScanningFile;
  final int scannedCount;

  const AuditScanningState({
    required this.currentScanningFile,
    required this.scannedCount,
  });

  @override
  List<Object?> get props => [currentScanningFile, scannedCount];
}

class AuditSuccessState extends AuditState {
  final ScanResult scanResult;
  final Severity? selectedSeverity;
  final IssueCategory? selectedCategory;
  final String searchQuery;

  const AuditSuccessState({
    required this.scanResult,
    this.selectedSeverity,
    this.selectedCategory,
    this.searchQuery = '',
  });

  AuditSuccessState copyWith({
    ScanResult? scanResult,
    Severity? selectedSeverity,
    bool clearSeverity = false,
    IssueCategory? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
  }) {
    return AuditSuccessState(
      scanResult: scanResult ?? this.scanResult,
      selectedSeverity: clearSeverity ? null : (selectedSeverity ?? this.selectedSeverity),
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<SecurityIssue> get filteredIssues {
    return scanResult.issues.where((issue) {
      if (selectedSeverity != null && issue.severity != selectedSeverity) {
        return false;
      }
      if (selectedCategory != null && issue.category != selectedCategory) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchTitle = issue.title.toLowerCase().contains(query);
        final matchFile = issue.filePath.toLowerCase().contains(query);
        final matchDesc = issue.description.toLowerCase().contains(query);
        return matchTitle || matchFile || matchDesc;
      }
      return true;
    }).toList();
  }

  @override
  List<Object?> get props => [scanResult, selectedSeverity, selectedCategory, searchQuery];
}

class AuditErrorState extends AuditState {
  final String message;

  const AuditErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportExportedState extends AuditState {
  final String filePath;

  const ReportExportedState(this.filePath);

  @override
  List<Object?> get props => [filePath];
}
