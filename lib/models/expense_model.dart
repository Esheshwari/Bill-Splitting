enum SplitType { equal, unequal, percentage }

class ExpenseShare {
  const ExpenseShare({
    required this.userId,
    required this.amount,
    this.percentage,
  });

  final String userId;
  final double amount;
  final double? percentage;
}

class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.groupId,
    required this.amount,
    required this.paidBy,
    required this.title,
    required this.category,
    required this.shares,
    required this.timestamp,
    required this.splitType,
    this.note,
    this.receiptPath,
  });

  final String id;
  final String groupId;
  final double amount;
  final String paidBy;
  final String title;
  final String category;
  final List<ExpenseShare> shares;
  final DateTime timestamp;
  final SplitType splitType;
  final String? note;
  final String? receiptPath;
}

