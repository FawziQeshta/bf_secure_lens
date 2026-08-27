import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/security_issue.dart';

enum ExportFormat { pdf, markdown, json }

class ReportExporter {
  static String generateJson(ScanResult result) {
    final mapData = {
      'targetPath': result.targetPath,
      'scanTime': result.scanTime.toIso8601String(),
      'securityScore': result.securityScore,
      'totalFilesScanned': result.totalFilesScanned,
      'scanDurationMs': result.scanDuration.inMilliseconds,
      'summary': {
        'critical': result.criticalCount,
        'high': result.highCount,
        'medium': result.mediumCount,
        'low': result.lowCount,
        'info': result.infoCount,
      },
      'issues': result.issues.map((i) => {
        'id': i.id,
        'title': i.title,
        'description': i.description,
        'category': i.category.name,
        'severity': i.severity.name,
        'filePath': i.filePath,
        'lineNumber': i.lineNumber,
        'snippet': i.snippet,
        'remediationAdvice': i.remediationAdvice,
        'secureCodeExample': i.secureCodeExample,
        'cweOrOwasp': i.cweOrOwasp,
      }).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(mapData);
  }

  static String generateMarkdown(ScanResult result) {
    final buffer = StringBuffer();

    buffer.writeln('# 🛡️ BF SecureLens - Security Audit & Advisory Report');
    buffer.writeln();
    buffer.writeln('**Target Path:** `${result.targetPath}`  ');
    buffer.writeln('**Scan Time:** ${result.scanTime.toLocal()}  ');
    buffer.writeln('**Total Files Scanned:** ${result.totalFilesScanned}  ');
    buffer.writeln('**Duration:** ${result.scanDuration.inMilliseconds} ms  ');
    buffer.writeln('**Security Score:** **${result.securityScore} / 100**  ');
    buffer.writeln();

    buffer.writeln('---');
    buffer.writeln('## 📊 Severity Breakdown');
    buffer.writeln('- 🔴 **Critical:** ${result.criticalCount}');
    buffer.writeln('- 🟠 **High:** ${result.highCount}');
    buffer.writeln('- 🟡 **Medium:** ${result.mediumCount}');
    buffer.writeln('- 🔵 **Low:** ${result.lowCount}');
    buffer.writeln('- ℹ️ **Info:** ${result.infoCount}');
    buffer.writeln();

    buffer.writeln('---');
    buffer.writeln('## 🚨 Identified Security Gaps & Remediation Advice');
    buffer.writeln();

    if (result.issues.isEmpty) {
      buffer.writeln('✅ **No security gaps detected during this scan!**');
    } else {
      for (int i = 0; i < result.issues.length; i++) {
        final issue = result.issues[i];
        buffer.writeln('### ${i + 1}. [${issue.severity.name.toUpperCase()}] ${issue.title}');
        buffer.writeln('**Category:** `${issue.category.name}`  ');
        buffer.writeln('**File Location:** `${issue.filePath}:${issue.lineNumber}`  ');
        buffer.writeln('**CWE / OWASP:** `${issue.cweOrOwasp}`  ');
        buffer.writeln();
        buffer.writeln('**Description:**  ');
        buffer.writeln(issue.description);
        buffer.writeln();
        buffer.writeln('**Vulnerable Snippet:**  ');
        buffer.writeln('```');
        buffer.writeln(issue.snippet);
        buffer.writeln('```');
        buffer.writeln();
        buffer.writeln('💡 **Remediation & Advice:**  ');
        buffer.writeln(issue.remediationAdvice);
        buffer.writeln();
        buffer.writeln('🔒 **Recommended Secure Implementation:**  ');
        buffer.writeln('```dart');
        buffer.writeln(issue.secureCodeExample);
        buffer.writeln('```');
        buffer.writeln();
        buffer.writeln('---');
      }
    }

    return buffer.toString();
  }

  static Future<Uint8List> generatePdf(ScanResult result) async {
    final pdf = pw.Document();

    PdfColor getSeverityColor(Severity severity) {
      switch (severity) {
        case Severity.critical:
          return PdfColors.red;
        case Severity.high:
          return PdfColors.orange;
        case Severity.medium:
          return PdfColors.amber;
        case Severity.low:
          return PdfColors.blue;
        case Severity.info:
          return PdfColors.teal;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Title Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'BF SECURE LENS',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.cyan900,
                  ),
                ),
                pw.Text(
                  'Security Audit Report',
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.cyan900),
            pw.SizedBox(height: 10),

            // Metadata & Health Score Card
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Target Path: ${result.targetPath}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('Scan Date: ${result.scanTime.toLocal()}', style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 2),
                        pw.Text('Total Files Scanned: ${result.totalFilesScanned} | Duration: ${result.scanDuration.inMilliseconds} ms', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: pw.BoxDecoration(
                      color: result.securityScore >= 85
                          ? PdfColors.green100
                          : result.securityScore >= 60
                              ? PdfColors.orange100
                              : PdfColors.red100,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(
                        color: result.securityScore >= 85
                            ? PdfColors.green800
                            : result.securityScore >= 60
                                ? PdfColors.orange800
                                : PdfColors.red800,
                      ),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          '${result.securityScore}%',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: result.securityScore >= 85
                                ? PdfColors.green900
                                : result.securityScore >= 60
                                    ? PdfColors.orange900
                                    : PdfColors.red900,
                          ),
                        ),
                        pw.Text('Health Score', style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // Severity Counts Table
            pw.Text('Severity Summary', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['Critical', 'High', 'Medium', 'Low', 'Info', 'Total Issues'],
              data: [
                [
                  result.criticalCount.toString(),
                  result.highCount.toString(),
                  result.mediumCount.toString(),
                  result.lowCount.toString(),
                  result.infoCount.toString(),
                  result.issues.length.toString(),
                ]
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignment: pw.Alignment.center,
            ),
            pw.SizedBox(height: 16),

            // Findings Section
            pw.Text('Security Findings & Remediation Advice', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),

            if (result.issues.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text('No security gaps detected during this scan!', style: pw.TextStyle(color: PdfColors.green900, fontWeight: pw.FontWeight.bold)),
              )
            else
              ...result.issues.map((issue) {
                final sevColor = getSeverityColor(issue.severity);
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: pw.BoxDecoration(
                              color: sevColor,
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Text(
                              issue.severity.name.toUpperCase(),
                              style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Expanded(
                            child: pw.Text(
                              issue.title,
                              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.Text(issue.cweOrOwasp, style: const pw.TextStyle(fontSize: 8, color: PdfColors.cyan900)),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Location: ${issue.filePath}:${issue.lineNumber}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text(issue.description, style: const pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 6),

                      // Vulnerable snippet box
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(6),
                        decoration: pw.BoxDecoration(color: PdfColors.red50, borderRadius: pw.BorderRadius.circular(4)),
                        child: pw.Text('Vulnerable: ${issue.snippet}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.red900)),
                      ),
                      pw.SizedBox(height: 4),

                      // Remediation advice & Fix box
                      pw.Text('Remediation: ${issue.remediationAdvice}', style: pw.TextStyle(fontSize: 9, color: PdfColors.green900, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(6),
                        decoration: pw.BoxDecoration(color: PdfColors.green50, borderRadius: pw.BorderRadius.circular(4)),
                        child: pw.Text('Fix: ${issue.secureCodeExample}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.green900)),
                      ),
                    ],
                  ),
                );
              }),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static Future<String> exportToPdf(ScanResult result, String outputPath) async {
    final file = File(outputPath);
    final pdfBytes = await generatePdf(result);
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  static Future<String> exportToJson(ScanResult result, String outputPath) async {
    final file = File(outputPath);
    final jsonString = generateJson(result);
    await file.writeAsString(jsonString);
    return file.path;
  }

  static Future<String> exportToMarkdown(ScanResult result, String outputPath) async {
    final file = File(outputPath);
    final mdString = generateMarkdown(result);
    await file.writeAsString(mdString);
    return file.path;
  }
}
