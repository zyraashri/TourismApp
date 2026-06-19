import 'package:flutter/material.dart';
import '../models/trip_models.dart';
import '../services/firebase_service.dart';

class BudgetingPage extends StatefulWidget {
  final Trip trip;
  final String docId; 

  const BudgetingPage({Key? key, required this.trip, required this.docId}) : super(key: key);

  @override
  State<BudgetingPage> createState() => _BudgetingPageState();
}

class _BudgetingPageState extends State<BudgetingPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _expenseTitleController = TextEditingController();
  final TextEditingController _expenseAmountController = TextEditingController();

  Future<void> _syncExpensesToFirebase() async {
    List<Map<String, dynamic>> expenseData = widget.trip.expenses.map((e) => {
      'title': e.title,
      'amount': e.amount,
    }).toList();

    await _firebaseService.updateTripData(widget.docId, {'expenses': expenseData});
  }

  Future<void> _showEditBudgetDialog() {
    final TextEditingController budgetController = TextEditingController(
      text: widget.trip.budgetLimit > 0 ? widget.trip.budgetLimit.toStringAsFixed(0) : '',
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Update Trip Budget', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E3D39))),
        content: TextField(
          controller: budgetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter total limit (RM)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              double? newLimit = double.tryParse(budgetController.text);
              if (newLimit != null) {
                setState(() {
                  widget.trip.budgetLimit = newLimit;
                });
                await _firebaseService.updateTripData(widget.docId, {'budgetLimit': newLimit});
                Navigator.pop(context);
              }
            },
            child: const Text('Update', style: TextStyle(color: Color(0xFF2E3D39), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Future<void> _addExpenseItem() async {
    double? amount = double.tryParse(_expenseAmountController.text);
    if (_expenseTitleController.text.isNotEmpty && amount != null) {
      setState(() {
        widget.trip.expenses.add(ExpenseItem(title: _expenseTitleController.text, amount: amount));
      });

      await _syncExpensesToFirebase();

      _expenseTitleController.clear();
      _expenseAmountController.clear();
      Navigator.pop(context);
    }
  }

  // Deletes an individual expense item from the table list and runs cloud sync
  void _deleteExpenseItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Expense Row?'),
        content: const Text('Are you sure you want to delete this log entry from the ledger?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              setState(() {
                widget.trip.expenses.removeAt(index);
              });
              await _syncExpensesToFirebase();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Record Expense', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E3D39))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _expenseTitleController, decoration: const InputDecoration(hintText: 'Expense name (e.g. Dinner)')),
            const SizedBox(height: 8),
            TextField(controller: _expenseAmountController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Amount (RM)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: _addExpenseItem, child: const Text('Save', style: TextStyle(color: Color(0xFF2E3D39), fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double spentRatio = 0.0;
    if (widget.trip.budgetLimit > 0) {
      spentRatio = (widget.trip.totalSpent / widget.trip.budgetLimit).clamp(0.0, 1.0);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      appBar: AppBar(
        title: const Text('Budget Tracker', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xFF2E3D39),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'RM ${widget.trip.totalSpent.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                      ),
                      Text(
                        'Budget: RM ${widget.trip.budgetLimit.toStringAsFixed(2)}',
                        style: const TextStyle(color: Color(0xFFE5E2DA), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: spentRatio,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        spentRatio >= 0.9 ? Colors.redAccent : const Color(0xFF9FA8A6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1.5, color: Colors.white.withOpacity(0.2)), 
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showEditBudgetDialog,
                          icon: const Icon(Icons.edit, size: 16, color: Color(0xFF2E3D39)),
                          label: const Text('Edit Budget', style: TextStyle(color: Color(0xFF2E3D39), fontWeight: FontWeight.bold, fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showAddExpenseDialog,
                          icon: const Icon(Icons.add, size: 18, color: Color(0xFF2E3D39)),
                          label: const Text('Add Expense', style: TextStyle(color: Color(0xFF2E3D39), fontWeight: FontWeight.bold, fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 36),
            const Text('Expenses Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E3D39))),
            const SizedBox(height: 16),
            
            // EXPENSES DISPLAY VIEW PACKED INSIDE INTERACTIVE DATA LABELS TABLE
            Expanded(
              child: widget.trip.expenses.isEmpty
                  ? Center(child: Text('No expenses recorded yet.', style: TextStyle(color: Colors.grey[400], fontSize: 14)))
                  : SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(const Color(0xFFF3EFF7)),
                          horizontalMargin: 16,
                          columnSpacing: 12,
                          columns: const [
                            DataColumn(label: Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E3D39)))),
                            DataColumn(numeric: true, label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E3D39)))),
                            DataColumn(label: Text('', style: TextStyle(fontWeight: FontWeight.bold))), // Empty spacer column header for the delete tray
                          ],
                          rows: List<DataRow>.generate(widget.trip.expenses.length, (index) {
                            final expense = widget.trip.expenses[index];
                            return DataRow(
                              cells: [
                                DataCell(Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87))),
                                DataCell(Text('RM ${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)))),
                                
                                // INTERACTIVE ROW REMOVAL ACTION BUTTON CELL
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                                    onPressed: () => _deleteExpenseItem(index),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}