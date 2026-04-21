import 'dart:async';

import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import '../models/expense_model.dart';
import '../models/group_model.dart';
import 'expense_repository.dart';

class MockExpenseRepository implements ExpenseRepository {
  final _uuid = const Uuid();

  final List<AppUser> _users = const [
    AppUser(id: 'demo-user', name: 'Aarav', email: 'aarav@mail.com', avatarUrl: ''),
    AppUser(id: 'u2', name: 'Mira', email: 'mira@mail.com', avatarUrl: ''),
    AppUser(id: 'u3', name: 'Kabir', email: 'kabir@mail.com', avatarUrl: ''),
  ];

  late final List<GroupModel> _groups = [
    const GroupModel(
      id: 'g1',
      name: 'Goa Escape',
      icon: 'beach_access',
      memberIds: ['demo-user', 'u2', 'u3'],
      createdBy: 'demo-user',
    ),
    const GroupModel(
      id: 'g2',
      name: 'Flatmates',
      icon: 'home',
      memberIds: ['demo-user', 'u2'],
      createdBy: 'demo-user',
    ),
  ];

  late final List<ExpenseModel> _expenses = [
    ExpenseModel(
      id: _uuid.v4(),
      groupId: 'g1',
      amount: 2400,
      paidBy: 'demo-user',
      title: 'Dinner by the beach',
      category: 'Food',
      shares: const [
        ExpenseShare(userId: 'demo-user', amount: 800),
        ExpenseShare(userId: 'u2', amount: 800),
        ExpenseShare(userId: 'u3', amount: 800),
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      splitType: SplitType.equal,
      note: 'Sunset cafe',
    ),
    ExpenseModel(
      id: _uuid.v4(),
      groupId: 'g1',
      amount: 1500,
      paidBy: 'u2',
      title: 'Scooter rental',
      category: 'Travel',
      shares: const [
        ExpenseShare(userId: 'demo-user', amount: 500),
        ExpenseShare(userId: 'u2', amount: 500),
        ExpenseShare(userId: 'u3', amount: 500),
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      splitType: SplitType.equal,
    ),
  ];

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    _expenses.insert(0, expense);
  }

  @override
  Future<void> addGroup(GroupModel group) async {
    _groups.insert(0, group);
  }

  @override
  Future<List<ExpenseModel>> fetchExpenses(String groupId) async {
    return _expenses.where((expense) => expense.groupId == groupId).toList();
  }

  @override
  Future<List<GroupModel>> fetchGroups(String userId) async {
    return _groups.where((group) => group.memberIds.contains(userId)).toList();
  }

  @override
  Future<List<AppUser>> fetchUsers(String groupId) async {
    final group = _groups.firstWhere((element) => element.id == groupId);
    return _users.where((user) => group.memberIds.contains(user.id)).toList();
  }

  @override
  Future<void> updateGroup(GroupModel group) async {
    final index = _groups.indexWhere((item) => item.id == group.id);
    if (index >= 0) _groups[index] = group;
  }
}

