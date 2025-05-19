import 'package:application/models/statement.dart';
import 'package:application/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ComponentTransaction extends StatefulWidget {
  final Transaction transaction;
  final void Function()? onDelete;

  const ComponentTransaction({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  @override
  State<ComponentTransaction> createState() => _ComponentTransactionState();
}

class _ComponentTransactionState extends State<ComponentTransaction> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Gets the user statement.
    final statement = Provider.of<Statement>(context);

    final t = widget.transaction;
    final formattedDate = DateFormat('yyyy-MM-dd').format(t.date);
    final formattedAmount =
        t.amount > 0
            ? "+${statement.formatter.format(t.amount)}"
            : statement.formatter.format(t.amount);
    final amountColor = t.amount >= 0 ? Colors.greenAccent : Colors.redAccent;

    return GestureDetector(
      onTap: _toggleExpanded,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white70,
                        size: 18,
                      ),
                      SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            t.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  formattedAmount,
                  style: TextStyle(
                    color: amountColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            if (_isExpanded) ...[
              const SizedBox(height: 10),
              Text(
                t.description,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            backgroundColor: const Color(0xFF1E1E2C),
                            title: const Text(
                              "Delete Transaction",
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              "Are you sure?",
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                    );

                    if (confirmed == true) {
                      widget.onDelete?.call();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
