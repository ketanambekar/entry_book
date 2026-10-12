import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/models/account_model.dart';
import '../utils/constants.dart';

class ExportResult {
  ExportResult({
    required this.path,
    required this.message,
    required this.usedFallback,
  });

  final String path;
  final String message;
  final bool usedFallback;
}

class ExcelService {
  Future<ExportResult> exportAccounts(List<AccountModel> accounts) async {
    final excel = Excel.createExcel();
    final sheet = excel['Accounts'];

    sheet.appendRow(<CellValue>[
      TextCellValue('Account Number'),
      TextCellValue('Account Name'),
      TextCellValue('Status'),
      TextCellValue('Creation Date'),
      TextCellValue('Total Amount'),
      TextCellValue('Entry Date'),
      TextCellValue('Entry Amount'),
    ]);

    for (final account in accounts) {
      if (account.entries.isEmpty) {
        sheet.appendRow(<CellValue>[
          TextCellValue(account.accountNumber),
          TextCellValue(account.accountName),
          TextCellValue(account.status.name.toUpperCase()),
          TextCellValue(account.creationDate.toIso8601String()),
          DoubleCellValue(account.totalAmount),
          TextCellValue(''),
          TextCellValue(''),
        ]);
      } else {
        for (final entry in account.entries) {
          sheet.appendRow(<CellValue>[
            TextCellValue(account.accountNumber),
            TextCellValue(account.accountName),
            TextCellValue(account.status.name.toUpperCase()),
            TextCellValue(account.creationDate.toIso8601String()),
            DoubleCellValue(account.totalAmount),
            TextCellValue(entry.date.toIso8601String()),
            DoubleCellValue(entry.amount),
          ]);
        }
      }
    }

    excel.delete('Sheet1');
    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Failed to generate Excel bytes');
    }

    final canWriteDownloadFolder = await _canWriteDownloadsDirectory();
    var usedFallback = false;
    var message = 'Excel backup updated successfully';

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
        File('${preferredDirectory.path}/${AppConstants.exportFileName}');

    try {
      await preferredFile.writeAsBytes(bytes, flush: true);
      return ExportResult(
        path: preferredFile.path,
        message: message,
        usedFallback: usedFallback,
      );
    } catch (_) {
      final docsDir = await getApplicationDocumentsDirectory();
      final fallbackFile = File('${docsDir.path}/${AppConstants.exportFileName}');
      await fallbackFile.writeAsBytes(bytes, flush: true);
      return ExportResult(
        path: fallbackFile.path,
        message:
            'Could not write to preferred folder, backup saved in app documents folder',
        usedFallback: true,
      );
    }
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
