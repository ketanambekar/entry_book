import 'package:get_storage/get_storage.dart';

import '../data/models/account_model.dart';
import '../utils/constants.dart';

class StorageService {
  final GetStorage _box = GetStorage();

  List<AccountModel> readAccounts() {
    final raw = _box.read<List<dynamic>>(AppConstants.storageAccountsKey) ?? <dynamic>[];
    return raw
        .map((e) => AccountModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> writeAccounts(List<AccountModel> accounts) {
    final payload = accounts.map((a) => a.toMap()).toList();
    return _box.write(AppConstants.storageAccountsKey, payload);
  }
}
