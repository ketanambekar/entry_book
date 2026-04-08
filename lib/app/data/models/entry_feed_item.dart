class EntryFeedItem {
  EntryFeedItem({
    required this.accountName,
    required this.accountNumber,
    required this.amount,
    required this.date,
  });

  final String accountName;
  final String accountNumber;
  final double amount;
  final DateTime date;
}
