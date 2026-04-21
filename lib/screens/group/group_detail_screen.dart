import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_formatters.dart';
import '../../models/group_model.dart';
import '../../providers/app_provider.dart';
import '../../services/upi_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/expense_tile.dart';
import '../expense/add_expense_screen.dart';
import 'edit_group_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({
    super.key,
    required this.group,
  });

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final users = app.usersForGroup(group.id);
    final expenses = app.expensesForGroup(group.id);
    final settlements = app.settlementsForGroup(group.id);
    final userById = {for (final user in users) user.id: user};

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditGroupScreen(group: group),
                ),
              );
            },
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(group: group),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add expense'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settle up',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  if (settlements.isEmpty)
                    const Text('Everyone is settled. That was clean.')
                  else
                    ...settlements.map((settlement) {
                      final fromUser = userById[settlement.fromUserId];
                      final toUser = userById[settlement.toUserId];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('${fromUser?.name ?? 'Someone'} pays ${toUser?.name ?? 'Someone'}'),
                        subtitle: Text(AppFormatters.money(settlement.amount)),
                        trailing: TextButton(
                          onPressed: () async {
                            await UpiService.pay(
                              payeeName: toUser?.name ?? 'Friend',
                              upiId: 'friend@upi',
                              amount: settlement.amount,
                              note: '${group.name} settlement',
                            );
                          },
                          child: const Text('Pay now'),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Recent expenses',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          if (expenses.isEmpty)
            const EmptyState(
              title: 'No expenses yet',
              subtitle: 'Go spend something and let SplitSmart do the math.',
              icon: Icons.receipt_long_rounded,
            )
          else
            ...expenses.map(
              (expense) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ExpenseTile(expense: expense, users: users),
              ),
            ),
        ],
      ),
    );
  }
}
