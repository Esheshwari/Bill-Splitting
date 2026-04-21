import 'package:flutter/material.dart';

import '../core/utils/app_formatters.dart';
import '../models/app_user.dart';
import '../models/expense_model.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.users,
  });

  final ExpenseModel expense;
  final List<AppUser> users;

  @override
  Widget build(BuildContext context) {
    final payer = users.where((user) => user.id == expense.paidBy).first;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: CircleAvatar(
          child: Icon(_iconForCategory(expense.category)),
        ),
        title: Text(expense.title),
        subtitle: Text(
          'Paid by ${payer.name} · ${AppFormatters.shortDate(expense.timestamp)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppFormatters.money(expense.amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(expense.category),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Travel':
        return Icons.directions_car_filled_rounded;
      case 'Rent':
        return Icons.house_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
}

