import 'package:application/helper/data_transactions.dart';
import 'package:application/models/transaction.dart';
import 'package:application/dashboard/transactions/component_transaction.dart';
import 'package:application/dashboard/transactions/page_create_transaction.dart';
import 'package:flutter/material.dart';

class ComponentTransactionList extends StatefulWidget {
  const ComponentTransactionList({super.key});

  @override
  State<ComponentTransactionList> createState() =>
      _ComponentTransactionListState();
}

class _ComponentTransactionListState extends State<ComponentTransactionList> {
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  /// Size of each page.
  final int pageSize = 10;

  /// Amount of transactions being displayed.
  int displayedCount = 10;

  /// Transactions list to be passed to the transactions screen.
  List<Transaction> _transactions = [];

  /// Load more transactions.
  void _loadMore() {
    setState(() {
      displayedCount = (displayedCount + pageSize).clamp(
        0,
        _transactions.length,
      );
    });
  }

  /// Navigate to the create transaction page.
  void _navigateCreateTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PageCreateTransaction()),
    ).then((result) {
      _loadTransactions();
      displayedCount = 10;
    });
  }

  /// Populating the transactions.
  Future<void> _loadTransactions() async {
    final result = await fetchTransactions();
    setState(() {
      _transactions = result;
    });
  }

  /// Deletes the selected transactions.
  Future<bool> _deleteTransaction(int? id) async {
    bool result = await deleteTransaction(id);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final transactionsToShow = _transactions.take(displayedCount).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateCreateTransaction,
        foregroundColor: Colors.black,
        backgroundColor: Colors.cyan,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: transactionsToShow.length + 1,
        itemBuilder: (context, index) {
          if (_transactions.isEmpty) {
            return Column(
              children: [
                SizedBox(height: 100.0),
                Icon(Icons.payments_outlined, color: Colors.white, size: 100),
                Text(
                  "No transactions recorded!",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ],
            );
          } else {
            if (index < transactionsToShow.length) {
              return ComponentTransaction(
                key: ValueKey(transactionsToShow[index].id),
                transaction: transactionsToShow[index],
                onDelete: () async {
                  bool success = await _deleteTransaction(
                    transactionsToShow[index].id,
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Transaction deleted"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to delete"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                  _loadTransactions(); // Refresh the transactions.
                },
              );
            } else {
              // Show load more button only if there are more transactions.
              if (displayedCount < _transactions.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E2C),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _loadMore,
                    child: const Text(
                      'Load More',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }
          }
        },
      ),
    );
  }
}
