import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/models/account_model.dart';
import '../data/models/entry_model.dart';
import '../utils/constants.dart';

class CsvImportResult {
  CsvImportResult({
    required this.accounts,
    required this.issues,
  });

  final List<AccountModel> accounts;
  final List<String> issues;
}

class CsvExportResult {
  CsvExportResult({
    required this.path,
    required this.message,
    required this.usedFallback,
  });

  final String path;
  final String message;
  final bool usedFallback;
}

class CsvService {
  Future<CsvExportResult> exportBackupCsv(List<AccountModel> accounts) async {
    final rows = <List<dynamic>>[
      <String>[
        'TYPE',
        'AccountNumber',
        'AccountName',
        'CreationDate',
        'Status',
        'TotalAmount',
        'ClosingAmount',
      ],
    ];

    for (final account in accounts) {
      rows.add(<dynamic>[
        'ACCOUNT',
        account.accountNumber,
        account.accountName,
        account.creationDate.toIso8601String(),
        account.status.name,
        account.totalAmount.toStringAsFixed(2),
        account.closingAmount?.toStringAsFixed(2) ?? '',
      ]);

      for (final entry in account.entries) {
        rows.add(<dynamic>[
          'ENTRY',
          account.accountNumber,
          entry.date.toIso8601String(),
          entry.amount.toStringAsFixed(2),
        ]);
      }
    }

    final csv = const ListToCsvConverter().convert(rows);
    final canWriteDownloadFolder = await _canWriteDownloadsDirectory();
    var usedFallback = false;
    var message = 'Backup downloaded successfully';

    Directory? preferredDirectory;
    if (canWriteDownloadFolder) {
      preferredDirectory = Directory('/storage/emulated/0/Download');
      if (!await preferredDirectory.exists()) {
        preferredDirectory = null;
      }
    }

    if (!canWriteDownloadFolder) {
      usedFallback = true;
      message = 'Storage permission denied, backup saved in app documents folder';
    }

    preferredDirectory ??= await getApplicationDocumentsDirectory();
    final preferredFile =
        File('${preferredDirectory.path}/${AppConstants.csvBackupFileName}');

    try {
      await preferredFile.writeAsString(csv, encoding: utf8, flush: true);
      return CsvExportResult(
        path: preferredFile.path,
        message: message,
        usedFallback: usedFallback,
      );
    } catch (_) {
      final docsDir = await getApplicationDocumentsDirectory();
      final fallbackFile = File('${docsDir.path}/${AppConstants.csvBackupFileName}');
      await fallbackFile.writeAsString(csv, encoding: utf8, flush: true);
      return CsvExportResult(
        path: fallbackFile.path,
        message:
            'Could not write to Downloads, backup saved in app documents folder',
        usedFallback: true,
      );
    }
  }

  Future<CsvImportResult?> pickAndParseCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['csv'],
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    final file = File(result.files.single.path!);
    final content = await file.readAsString(encoding: utf8);
    final rows = const CsvToListConverter(eol: '\n').convert(content);
    final issues = <String>[];

    if (rows.isEmpty) {
      return CsvImportResult(accounts: <AccountModel>[], issues: <String>['CSV is empty']);
    }

    final Map<String, AccountModel> accountMap = <String, AccountModel>{};
    final firstCell = rows.first.isEmpty ? '' : rows.first[0].toString().trim().toUpperCase();
    final startIndex = firstCell == 'TYPE' ? 1 : 0;

    if (startIndex == 0) {
      issues.add('Header row not found. Parsed rows as raw data.');
    }

    for (var i = startIndex; i < rows.length; i++) {
      final row = rows[i].map((e) => e.toString()).toList();
      if (row.isEmpty) {
        continue;
      }

      final type = row[0].trim().toUpperCase();
      if (type == 'ACCOUNT') {
        if (row.length < 6) {
          issues.add('Row ${i + 1}: ACCOUNT row has insufficient columns');
          continue;
        }

        final number = row[1].trim();
        if (number.isEmpty) {
          issues.add('Row ${i + 1}: Account number is required for ACCOUNT row');
          continue;
        }

        final name = row[2].trim();
        if (name.isEmpty) {
          issues.add('Row ${i + 1}: Account name is required for ACCOUNT row');
          continue;
        }

        final creationRaw = row[3].trim();
        DateTime creationDate;
        if (creationRaw.isEmpty) {
          creationDate = DateTime.now();
          issues.add('Row ${i + 1}: Missing creation date, used current date');
        } else {
          creationDate = DateTime.tryParse(creationRaw) ?? DateTime.now();
          if (DateTime.tryParse(creationRaw) == null) {
            issues.add('Row ${i + 1}: Invalid creation date "$creationRaw", used current date');
          }
        }

        final statusRaw = row[4].trim().toLowerCase();
        AccountStatus status;
        if (statusRaw == AccountStatus.active.name ||
            statusRaw == AccountStatus.closed.name) {
          status = statusRaw == AccountStatus.closed.name
              ? AccountStatus.closed
              : AccountStatus.active;
        } else {
          status = AccountStatus.active;
          issues.add('Row ${i + 1}: Invalid status "$statusRaw", defaulted to active');
        }

        final totalRaw = row[5].trim();
        final totalAmount = double.tryParse(totalRaw);
        if (totalAmount == null) {
          issues.add('Row ${i + 1}: Invalid total amount "$totalRaw", defaulted to 0');
        }

        accountMap[number] = AccountModel(
          accountNumber: number,
          accountName: name,
          creationDate: creationDate,
          status: status,
          totalAmount: totalAmount ?? 0,
          entries: <EntryModel>[],
          closingAmount: row.length > 6 ? double.tryParse(row[6].trim()) : null,
        );
      } else if (type == 'ENTRY') {
        if (row.length < 4) {
          issues.add('Row ${i + 1}: ENTRY row has insufficient columns');
          continue;
        }

        final number = row[1].trim();
        if (number.isEmpty) {
          issues.add('Row ${i + 1}: Account number is required for ENTRY row');
          continue;
        }

        final existing = accountMap[number];
        if (existing == null) {
          issues.add(
            'Row ${i + 1}: ENTRY references unknown account "$number" and was skipped',
          );
          continue;
        }

        final dateRaw = row[2].trim();
        final parsedDate = DateTime.tryParse(dateRaw);
        if (parsedDate == null && dateRaw.isNotEmpty) {
          issues.add('Row ${i + 1}: Invalid entry date "$dateRaw", used current date');
        }

        final amountRaw = row[3].trim();
        final parsedAmount = double.tryParse(amountRaw);
        if (parsedAmount == null) {
          issues.add('Row ${i + 1}: Invalid entry amount "$amountRaw", row skipped');
          continue;
        }

        final parsedEntries = List<EntryModel>.from(existing.entries)
          ..add(
            EntryModel(
              date: parsedDate ?? DateTime.now(),
              amount: parsedAmount,
            ),
          );

        accountMap[number] = existing.copyWith(entries: parsedEntries);
      } else {
        issues.add('Row ${i + 1}: Unknown row type "$type" and was skipped');
      }
    }

    return CsvImportResult(
      accounts: accountMap.values.toList(),
      issues: issues,
    );
  }

  Future<bool> _canWriteDownloadsDirectory() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      return true;
    }

    final status = await Permission.storage.request();
    return status.isGranted;
  }
}
