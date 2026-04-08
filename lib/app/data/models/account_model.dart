import 'entry_model.dart';

enum AccountStatus { active, closed }

class AccountModel {
  AccountModel({
    required this.accountName,
    required this.accountNumber,
    required this.creationDate,
    required this.totalAmount,
    required this.status,
    required this.entries,
    this.closingAmount,
  });

  final String accountName;
  final String accountNumber;
  final DateTime creationDate;
  final double totalAmount;
  final AccountStatus status;
  final List<EntryModel> entries;
  final double? closingAmount;

  bool get isClosed => status == AccountStatus.closed;

  AccountModel copyWith({
    String? accountName,
    String? accountNumber,
    DateTime? creationDate,
    double? totalAmount,
    AccountStatus? status,
    List<EntryModel>? entries,
    double? closingAmount,
  }) {
    return AccountModel(
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      creationDate: creationDate ?? this.creationDate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      entries: entries ?? this.entries,
      closingAmount: closingAmount ?? this.closingAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountName': accountName,
      'accountNumber': accountNumber,
      'creationDate': creationDate.toIso8601String(),
      'totalAmount': totalAmount,
      'status': status.name,
      'entries': entries.map((e) => e.toMap()).toList(),
      'closingAmount': closingAmount,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      accountName: map['accountName'] as String,
      accountNumber: map['accountNumber'] as String,
      creationDate: DateTime.parse(map['creationDate'] as String),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      status: (map['status'] as String) == AccountStatus.closed.name
          ? AccountStatus.closed
          : AccountStatus.active,
      entries: (map['entries'] as List<dynamic>? ?? <dynamic>[])
          .map((e) => EntryModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      closingAmount: map['closingAmount'] == null
          ? null
          : (map['closingAmount'] as num).toDouble(),
    );
  }
}
