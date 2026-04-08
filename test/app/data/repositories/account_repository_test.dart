import 'package:entry_book/app/data/models/account_model.dart';
import 'package:entry_book/app/data/models/entry_model.dart';
import 'package:entry_book/app/data/providers/local_storage_provider.dart';
import 'package:entry_book/app/data/repositories/account_repository.dart';
import 'package:entry_book/app/services/csv_service.dart';
import 'package:entry_book/app/services/excel_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _InMemoryStorageProvider implements AccountStorageProvider {
  List<AccountModel> _stored = <AccountModel>[];

  @override
  List<AccountModel> getAccounts() => _stored;

  @override
  Future<void> saveAccounts(List<AccountModel> accounts) async {
    _stored = List<AccountModel>.from(accounts);
  }
}

class _FakeExcelService extends ExcelService {
  int exportCalls = 0;

  @override
  Future<ExportResult> exportAccounts(List<AccountModel> accounts) async {
    exportCalls += 1;
    return ExportResult(
      path: '/tmp/entry_book_export.xlsx',
      message: 'Exported',
      usedFallback: false,
    );
  }
}

class _FakeCsvService extends CsvService {
  CsvImportResult? result;

  @override
  Future<CsvImportResult?> pickAndParseCsv() async => result;
}

void main() {
  late AccountRepository repository;
  late _FakeExcelService excel;
  late _FakeCsvService csv;

  setUp(() async {
    final storage = _InMemoryStorageProvider();
    excel = _FakeExcelService();
    csv = _FakeCsvService();

    repository = AccountRepository(
      storageProvider: storage,
      excelService: excel,
      csvService: csv,
    );
    await repository.load();
  });

  test('createAccount prevents duplicate account numbers', () async {
    final first = await repository.createAccount(
      accountName: 'A',
      accountNumber: '1001',
      amount: 100,
      creationDate: DateTime(2026, 1, 1),
    );
    final second = await repository.createAccount(
      accountName: 'B',
      accountNumber: '1001',
      amount: 200,
      creationDate: DateTime(2026, 1, 2),
    );

    expect(first, isNull);
    expect(second, 'Account number already exists');
    expect(repository.accounts.length, 1);
  });

  test('addEntry updates total and triggers excel export', () async {
    await repository.createAccount(
      accountName: 'A',
      accountNumber: '1002',
      amount: 100,
      creationDate: DateTime(2026, 1, 1),
    );

    final result = await repository.addEntry(
      accountNumber: '1002',
      amount: 25,
      date: DateTime(2026, 1, 2),
    );

    final account = repository.findByAccountNumber('1002');
    expect(result, isNull);
    expect(account, isNotNull);
    expect(account!.totalAmount, 125);
    expect(account.entries.length, 2);
    expect(excel.exportCalls, 1);
    expect(repository.lastExportPath.value, '/tmp/entry_book_export.xlsx');
  });

  test('closed account cannot receive new entries', () async {
    await repository.createAccount(
      accountName: 'A',
      accountNumber: '1003',
      amount: 100,
      creationDate: DateTime(2026, 1, 1),
    );

    final closeResult = await repository.closeAccount(
      accountNumber: '1003',
      closingAmount: 100,
    );
    final addResult = await repository.addEntry(
      accountNumber: '1003',
      amount: 10,
      date: DateTime(2026, 1, 3),
    );

    expect(closeResult, isNull);
    expect(addResult, 'Cannot add entry to closed account');
  });

  test('importFromCsv stores parsed accounts and warnings', () async {
    csv.result = CsvImportResult(
      accounts: <AccountModel>[
        AccountModel(
          accountName: 'Imported',
          accountNumber: '2001',
          creationDate: DateTime(2026, 2, 1),
          totalAmount: 50,
          status: AccountStatus.active,
          entries: <EntryModel>[
            EntryModel(amount: 50, date: DateTime(2026, 2, 1)),
          ],
        ),
      ],
      issues: <String>['Row 3: Invalid amount'],
    );

    final result = await repository.importFromCsv();

    expect(result, isNull);
    expect(repository.accounts.length, 1);
    expect(repository.accounts.first.accountNumber, '2001');
    expect(repository.lastImportIssues.length, 1);
  });
}
