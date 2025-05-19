import 'package:application/helper/data_transactions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PageCreateTransaction extends StatefulWidget {
  const PageCreateTransaction({super.key});

  @override
  State<PageCreateTransaction> createState() => _PageCreateTransactionState();
}

class _PageCreateTransactionState extends State<PageCreateTransaction> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      bool result = await createTransaction(
        _nameController.value.text,
        _descriptionController.value.text,
        double.parse(_amountController.value.text),
        _selectedDate,
      );
      if (result == true) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to create transaction."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(data: ThemeData.dark(), child: child!);
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1E1E2C),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Transaction"),
        backgroundColor: const Color(0xFF040C15),
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFF040C15),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Name'),
                style: const TextStyle(color: Colors.white),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Amount'),
                style: const TextStyle(color: Colors.white),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter an amount'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDecoration('Description'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C),
                    border: Border.all(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateFormatted,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.white70),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Add Transaction',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
