import 'package:entry_book/data/accounts/account.dart';

class DemoAccountRepository {
  const DemoAccountRepository();

  List<Account> getAccounts() {
    final accounts = [
      Account(
        name: 'Asha Patil',
        hasPendingInstalment: true,
        number: '000108',
        openingBalancePaise: 250000,
        createdAt: DateTime(2026, 10, 19, 15, 30),
      ),
      Account(
        name: 'Ravi Kumar',
        hasPendingInstalment: false,
        number: '000107',
        openingBalancePaise: 100050,
        createdAt: DateTime(2026, 10, 18, 11),
      ),
      Account(
        name: 'Meera Shah',
        hasPendingInstalment: true,
        number: '000106',
        openingBalancePaise: 0,
        createdAt: DateTime(2026, 10, 17, 16),
      ),
      Account(
        name: 'Imran Shaikh',
        hasPendingInstalment: true,
        number: '000105',
        openingBalancePaise: 500000,
        createdAt: DateTime(2026, 10, 16, 10),
      ),
      Account(
        name: 'Sunita Rao',
        hasPendingInstalment: false,
        number: '000104',
        openingBalancePaise: 75000,
        createdAt: DateTime(2026, 10, 15, 14),
      ),
      Account(
        name: 'Arjun Nair',
        hasPendingInstalment: true,
        number: '000103',
        openingBalancePaise: 150000,
        createdAt: DateTime(2026, 10, 14, 9),
      ),
      Account(
        name: 'Farah Khan',
        hasPendingInstalment: false,
        number: '000102',
        openingBalancePaise: 300000,
        createdAt: DateTime(2026, 10, 13, 12),
      ),
      Account(
        name: 'Vijay Desai',
        hasPendingInstalment: true,
        number: '000101',
        openingBalancePaise: 50000,
        createdAt: DateTime(2026, 10, 12, 17),
      ),
    ];
    accounts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(accounts);
  }
}
