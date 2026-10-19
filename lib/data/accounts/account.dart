class Account {
  const Account({
    required this.name,
    required this.number,
    required this.openingBalancePaise,
    required this.createdAt,
    required this.hasPendingInstalment,
  });

  final String name;
  final String number;
  final int openingBalancePaise;
  final DateTime createdAt;
  final bool hasPendingInstalment;
}
