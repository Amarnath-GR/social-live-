enum AccountType { user, platform, escrow }
enum EntryType { debit, credit }

class Account {
  final String id;
  final String userId;
  final AccountType type;
  final String currency;
  final DateTime createdAt;

  Account({
    required this.id,
    required this.userId,
    required this.type,
    required this.currency,
    required this.createdAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json['id'],
    userId: json['userId'],
    type: AccountType.values.byName(json['type']),
    currency: json['currency'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class JournalEntry {
  final String id;
  final String transactionId;
  final String accountId;
  final EntryType type;
  final double amount;
  final String description;
  final String? referenceId;
  final String? referenceType;
  final DateTime createdAt;
  final String hash;

  JournalEntry({
    required this.id,
    required this.transactionId,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.description,
    this.referenceId,
    this.referenceType,
    required this.createdAt,
    required this.hash,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'],
    transactionId: json['transactionId'],
    accountId: json['accountId'],
    type: EntryType.values.byName(json['type']),
    amount: json['amount'].toDouble(),
    description: json['description'],
    referenceId: json['referenceId'],
    referenceType: json['referenceType'],
    createdAt: DateTime.parse(json['createdAt']),
    hash: json['hash'],
  );
}

class Transaction {
  final String id;
  final List<JournalEntry> entries;
  final String description;
  final DateTime createdAt;
  final bool isReversed;

  Transaction({
    required this.id,
    required this.entries,
    required this.description,
    required this.createdAt,
    this.isReversed = false,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    entries: (json['entries'] as List).map((e) => JournalEntry.fromJson(e)).toList(),
    description: json['description'],
    createdAt: DateTime.parse(json['createdAt']),
    isReversed: json['isReversed'] ?? false,
  );
}

class Balance {
  final String accountId;
  final double amount;
  final String currency;
  final DateTime calculatedAt;

  Balance({
    required this.accountId,
    required this.amount,
    required this.currency,
    required this.calculatedAt,
  });

  factory Balance.fromJson(Map<String, dynamic> json) => Balance(
    accountId: json['accountId'],
    amount: json['amount'].toDouble(),
    currency: json['currency'],
    calculatedAt: DateTime.parse(json['calculatedAt']),
  );
}
