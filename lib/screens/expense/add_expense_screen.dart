import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/expense_model.dart';
import '../../models/group_model.dart';
import '../../providers/app_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({
    super.key,
    required this.group,
  });

  final GroupModel group;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final Map<String, TextEditingController> _shareControllers = {};
  SplitType _splitType = SplitType.equal;
  String _category = 'Food';
  String? _paidBy;
  String? _receiptPath;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    for (final controller in _shareControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final users = app.usersForGroup(widget.group.id);
    _paidBy ??= users.isNotEmpty ? users.first.id : null;
    for (final user in users) {
      _shareControllers.putIfAbsent(user.id, TextEditingController.new);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add expense')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'What was it for?'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _paidBy,
                    items: users
                        .map(
                          (user) => DropdownMenuItem(
                            value: user.id,
                            child: Text(user.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _paidBy = value),
                    decoration: const InputDecoration(labelText: 'Paid by'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _category,
                    items: const ['Food', 'Travel', 'Rent', 'Party', 'Shopping']
                        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) => setState(() => _category = value ?? 'Food'),
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<SplitType>(
                    value: _splitType,
                    items: SplitType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _splitType = value ?? SplitType.equal),
                    decoration: const InputDecoration(labelText: 'Split type'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(labelText: 'Note'),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _pickReceipt,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(_receiptPath == null ? 'Attach receipt' : 'Receipt attached'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Split between',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 14),
                  ...users.map((user) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: _shareControllers[user.id],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: _splitType == SplitType.percentage
                                ? '${user.name} %'
                                : '${user.name} amount',
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () async {
              final amount = double.tryParse(_amountController.text.trim()) ?? 0;
              final shares = _buildShares(users, amount);
              await app.addExpense(
                groupId: widget.group.id,
                amount: amount,
                title: _titleController.text.trim(),
                paidBy: _paidBy ?? users.first.id,
                category: _category,
                splitType: _splitType,
                shares: shares,
                note: _noteController.text.trim(),
                receiptPath: _receiptPath,
              );
              if (mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.monetization_on_rounded),
            label: const Text('Add expense'),
          )
              .animate()
              .shake(hz: 1.3, duration: 650.ms)
              .then()
              .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),
        ],
      ),
    );
  }

  Future<void> _pickReceipt() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _receiptPath = image.path);
  }

  List<ExpenseShare> _buildShares(List<AppUser> users, double amount) {
    if (_splitType == SplitType.equal) {
      final share = users.isEmpty ? 0 : amount / users.length;
      return users
          .map<ExpenseShare>((user) => ExpenseShare(userId: user.id, amount: share))
          .toList();
    }

    if (_splitType == SplitType.percentage) {
      // Convert percentages to amounts so settlement logic can stay uniform.
      return users.map<ExpenseShare>((user) {
        final percentage = double.tryParse(_shareControllers[user.id]!.text.trim()) ?? 0;
        return ExpenseShare(
          userId: user.id,
          percentage: percentage,
          amount: amount * (percentage / 100),
        );
      }).toList();
    }

    return users.map<ExpenseShare>((user) {
      final customAmount = double.tryParse(_shareControllers[user.id]!.text.trim()) ?? 0;
      return ExpenseShare(
        userId: user.id,
        amount: customAmount,
      );
    }).toList();
  }
}
