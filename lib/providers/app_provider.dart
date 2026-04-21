import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/settlement_engine.dart';
import '../models/app_user.dart';
import '../models/dashboard_summary.dart';
import '../models/expense_model.dart';
import '../models/group_model.dart';
import '../models/settlement_model.dart';
import '../services/expense_repository.dart';

class AppProvider extends ChangeNotifier {
  AppProvider(this._repository);

  final ExpenseRepository _repository;
  final _uuid = const Uuid();

  List<GroupModel> groups = [];
  final Map<String, List<AppUser>> groupUsers = {};
  final Map<String, List<ExpenseModel>> groupExpenses = {};
  bool isLoading = true;
  String currentUserId = 'demo-user';

  Future<void> bootstrap() async {
    await loadGroups();
  }

  Future<void> bindUser(String userId) async {
    if (currentUserId == userId) return;
    currentUserId = userId;
    await loadGroups();
  }

  Future<void> loadGroups() async {
    isLoading = true;
    notifyListeners();
    groups = await _repository.fetchGroups(currentUserId);
    for (final group in groups) {
      groupUsers[group.id] = await _repository.fetchUsers(group.id);
      groupExpenses[group.id] = await _repository.fetchExpenses(group.id);
    }
    isLoading = false;
    notifyListeners();
  }

  List<AppUser> usersForGroup(String groupId) => groupUsers[groupId] ?? [];
  List<ExpenseModel> expensesForGroup(String groupId) => groupExpenses[groupId] ?? [];

  DashboardSummary dashboardSummary() {
    double owed = 0;
    double receive = 0;
    final Map<String, double> categorySpend = {};

    for (final expenses in groupExpenses.values) {
      for (final expense in expenses) {
        final myShare = expense.shares.where((share) => share.userId == currentUserId);
        for (final share in myShare) {
          if (expense.paidBy == currentUserId) {
            receive += expense.amount - share.amount;
          } else {
            owed += share.amount;
          }
        }
        categorySpend.update(
          expense.category,
          (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }
    }

    return DashboardSummary(
      totalOwed: owed,
      totalToReceive: receive,
      monthlyCategorySpend: categorySpend,
    );
  }

  List<SettlementModel> settlementsForGroup(String groupId) {
    return SettlementEngine.settle(expensesForGroup(groupId));
  }

  Future<void> addGroup({
    required String name,
    required String icon,
    required List<String> memberIds,
  }) async {
    final group = GroupModel(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      memberIds: memberIds,
      createdBy: currentUserId,
    );
    await _repository.addGroup(group);
    await loadGroups();
  }

  Future<void> updateGroup(GroupModel group) async {
    await _repository.updateGroup(group);
    await loadGroups();
  }

  Future<void> addExpense({
    required String groupId,
    required double amount,
    required String title,
    required String paidBy,
    required String category,
    required SplitType splitType,
    required List<ExpenseShare> shares,
    String? note,
    String? receiptPath,
  }) async {
    final expense = ExpenseModel(
      id: _uuid.v4(),
      groupId: groupId,
      amount: amount,
      paidBy: paidBy,
      title: title,
      category: category,
      shares: shares,
      timestamp: DateTime.now(),
      splitType: splitType,
      note: note,
      receiptPath: receiptPath,
    );
    await _repository.addExpense(expense);
    groupExpenses[groupId] = await _repository.fetchExpenses(groupId);
    notifyListeners();
  }

  String smartSuggestion() {
    final summary = dashboardSummary();
    if (summary.monthlyCategorySpend.isEmpty) {
      return 'No expenses yet, go spend something memorable.';
    }
    final top = summary.monthlyCategorySpend.entries.reduce(
      (current, next) => current.value > next.value ? current : next,
    );
    return 'You usually spend more on ${top.key.toLowerCase()}.';
  }
}
