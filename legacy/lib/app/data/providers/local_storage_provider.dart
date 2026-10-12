import '../models/account_model.dart';
import '../../services/storage_service.dart';

abstract class AccountStorageProvider {
  List<AccountModel> getAccounts();

  Future<void> saveAccounts(List<AccountModel> accounts);
}

class LocalStorageProvider implements AccountStorageProvider {
  LocalStorageProvider(this._storageService);

  final StorageService _storageService;

  @override
  List<AccountModel> getAccounts() => _storageService.readAccounts();

  @override
  Future<void> saveAccounts(List<AccountModel> accounts) {
    return _storageService.writeAccounts(accounts);
  }
}
