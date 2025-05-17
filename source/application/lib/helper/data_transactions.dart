import 'package:application/models/transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Transaction>> fetchTransactions() async {
  // final response = await Supabase.instance.client
  //     .from('transactions')
  //     .select()
  //     .order('date', ascending: false);

  // final List<Transaction> transactions = [];
  // for (final row in response) {
  //   Transaction transaction = Transaction.fromMap(row);
  //   transactions.add(transaction);
  // }

  // return transactions;

  return List.generate(30, (index) {
    return Transaction(
      name: "Transaction #${index + 1}",
      date: DateTime.now().subtract(Duration(days: index * 2)),
      amount: (index % 2 == 0 ? 50.0 : -30.0) + index,
      description:
          "This is the description of transaction #${index + 1}. "
          "It might be longer to test collapsing/expanding behavior.",
    );
  });
}
