abstract final class WithdrawalCalculator {
  static String? validateAmount(String? value, {bool optional = false}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty && optional) return null;
    if (!RegExp(r'^[0-9]+(?:\.[0-9]{1,2})?$').hasMatch(text)) {
      return 'Enter 0 or more, with up to 2 decimal places.';
    }
    return null;
  }

  static BigInt parsePaise(String value) {
    if (validateAmount(value) != null) {
      throw FormatException('Invalid INR amount', value);
    }
    final parts = value.trim().split('.');
    return BigInt.parse(parts[0]) * BigInt.from(100) +
        BigInt.parse(parts.length == 1 ? '00' : parts[1].padRight(2, '0'));
  }

  static String formatPaise(BigInt paise) =>
      '${paise ~/ BigInt.from(100)}.${(paise % BigInt.from(100)).toString().padLeft(2, '0')}';

  static int completedMonths(DateTime opened, DateTime withdrawn) {
    final start = DateTime(opened.year, opened.month, opened.day);
    final end = DateTime(withdrawn.year, withdrawn.month, withdrawn.day);
    if (end.isBefore(start)) {
      throw ArgumentError('Withdrawal cannot precede opening');
    }
    var months = (end.year - start.year) * 12 + end.month - start.month;
    final lastDay = DateTime(end.year, end.month + 1, 0).day;
    final anniversaryDay = start.day > lastDay ? lastDay : start.day;
    if (end.day < anniversaryDay) months--;
    return months;
  }

  static WithdrawalEstimate estimate(BigInt principalPaise, int months) {
    if (principalPaise.isNegative || months < 0) {
      throw ArgumentError(
        'Principal and completed months must be non-negative',
      );
    }
    // Round once to the nearest paise, half up, without floating-point money.
    BigInt rounded(BigInt numerator, int denominator) =>
        (numerator * BigInt.two + BigInt.from(denominator)) ~/
        BigInt.from(denominator * 2);
    return WithdrawalEstimate(
      principalPaise: principalPaise,
      completedMonths: months,
      interestPaise: months < 6
          ? BigInt.zero
          : rounded(principalPaise * BigInt.from(months), 300),
      deductionPaise: months < 6
          ? rounded(principalPaise * BigInt.from(3), 100)
          : BigInt.zero,
    );
  }
}

class WithdrawalEstimate {
  const WithdrawalEstimate({
    required this.principalPaise,
    required this.completedMonths,
    required this.interestPaise,
    required this.deductionPaise,
  });

  final BigInt principalPaise;
  final int completedMonths;
  final BigInt interestPaise;
  final BigInt deductionPaise;
  BigInt get payoutPaise => principalPaise + interestPaise - deductionPaise;
}
