class Transaction {
  final int? id;
  final String name;
  final String description;
  final double amount;
  final DateTime date;

  Transaction({
    this.id,
    this.name = 'Transaction',
    this.description = '',
    required this.amount,
    required this.date,
  });

  factory Transaction.createTransaction(
    String? name,
    String? description,
    double? amount,
    DateTime date,
  ) {
    return Transaction(
      name: name ?? 'Transaction',
      description: description ?? 'No description.',
      amount: amount ?? 0.0,
      date: date,
    );
  }

  /// Convert from Supabase/Postgres map (JSON) to Transaction object
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      name: map['name'] ?? 'Transaction',
      description: map['description'] ?? 'No description.',
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
    );
  }

  /// Convert Transaction object to map for insert/update
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String().substring(0, 10),
    };
  }
}
