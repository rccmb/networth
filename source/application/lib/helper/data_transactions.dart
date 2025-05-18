import 'package:application/models/transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Transaction>> fetchTransactions() async {
  final response = await Supabase.instance.client
      .from('transactions')
      .select()
      .order('date', ascending: false);

  final List<Transaction> transactions = [];
  for (final row in response) {
    Transaction transaction = Transaction.fromMap(row);
    transactions.add(transaction);
  }

  return transactions;
}

Future<bool> createTransaction(
  String? name,
  String? description,
  double? amount,
  DateTime date,
) async {
  try {
    final transaction = Transaction.createTransaction(
      name,
      description,
      amount,
      date,
    );

    if (transaction.amount == 0.0) {
      return false;
    }

    final supabase = Supabase.instance.client;
    await supabase.from('transactions').insert({
      'name': transaction.name,
      'description': transaction.description,
      'amount': transaction.amount,
      'date': transaction.date.toIso8601String(),
    });

    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> deleteTransaction(int? id) async {
  if (id == null) return false;
  try {
    await Supabase.instance.client.from('transactions').delete().eq('id', id);
    return true;
  } catch (e) {
    return false;
  }
}
