enum TransactionType {
  income,
  expense;

  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Pemasukan';
      case TransactionType.expense:
        return 'Pengeluaran';
    }
  }

  String get icon {
    switch (this) {
      case TransactionType.income:
        return '📈';
      case TransactionType.expense:
        return '📉';
    }
  }
}
