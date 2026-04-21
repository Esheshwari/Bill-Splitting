import '../../models/expense_model.dart';
import '../../models/settlement_model.dart';

class SettlementEngine {
  static List<SettlementModel> settle(List<ExpenseModel> expenses) {
    final Map<String, double> net = {};

    for (final expense in expenses) {
      // Positive balance means the user should receive money back.
      net.update(
        expense.paidBy,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );

      for (final share in expense.shares) {
        net.update(
          share.userId,
          (value) => value - share.amount,
          ifAbsent: () => -share.amount,
        );
      }
    }

    final creditors = <_BalanceNode>[];
    final debtors = <_BalanceNode>[];

    net.forEach((userId, amount) {
      if (amount > 0.01) {
        creditors.add(_BalanceNode(userId, amount));
      } else if (amount < -0.01) {
        debtors.add(_BalanceNode(userId, -amount));
      }
    });

    creditors.sort((a, b) => b.amount.compareTo(a.amount));
    debtors.sort((a, b) => b.amount.compareTo(a.amount));

    final settlements = <SettlementModel>[];
    var i = 0;
    var j = 0;

    // Greedily match the largest debtor and creditor to minimize transfers.
    while (i < debtors.length && j < creditors.length) {
      final debtor = debtors[i];
      final creditor = creditors[j];
      final settledAmount = debtor.amount < creditor.amount
          ? debtor.amount
          : creditor.amount;

      settlements.add(
        SettlementModel(
          fromUserId: debtor.userId,
          toUserId: creditor.userId,
          amount: settledAmount,
        ),
      );

      debtor.amount -= settledAmount;
      creditor.amount -= settledAmount;

      if (debtor.amount <= 0.01) i++;
      if (creditor.amount <= 0.01) j++;
    }

    return settlements;
  }
}

class _BalanceNode {
  _BalanceNode(this.userId, this.amount);

  final String userId;
  double amount;
}
