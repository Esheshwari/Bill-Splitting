import '../models/app_user.dart';
import '../models/expense_model.dart';
import '../models/group_model.dart';

abstract class ExpenseRepository {
  Future<List<GroupModel>> fetchGroups(String userId);
  Future<List<AppUser>> fetchUsers(String groupId);
  Future<List<ExpenseModel>> fetchExpenses(String groupId);
  Future<void> addExpense(ExpenseModel expense);
  Future<void> addGroup(GroupModel group);
  Future<void> updateGroup(GroupModel group);
}

