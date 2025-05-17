import 'package:application/models/transaction.dart';
import 'package:application/transactions/component_transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ComponentTransactionList extends StatefulWidget {
  final NumberFormat euroFormat;
  final List<Transaction> transactions;

  const ComponentTransactionList({
    super.key,
    required this.euroFormat,
    required this.transactions,
  });

  @override
  State<ComponentTransactionList> createState() =>
      _ComponentTransactionListState();
}

class _ComponentTransactionListState extends State<ComponentTransactionList> {
  final int pageSize = 10;
  int displayedCount = 10;

  void _loadMore() {
    setState(() {
      displayedCount = (displayedCount + pageSize).clamp(
        0,
        widget.transactions.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsToShow =
        widget.transactions.take(displayedCount).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: transactionsToShow.length + 1,
      itemBuilder: (context, index) {
        if (index < transactionsToShow.length) {
          return ComponentTransaction(
            transaction: transactionsToShow[index],
            euroFormat: widget.euroFormat,
          );
        } else {
          // Show load more button only if there are more transactions.
          if (displayedCount < widget.transactions.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E2C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _loadMore,
                child: const Text('Load More', style: TextStyle(fontSize: 16)),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }
}
