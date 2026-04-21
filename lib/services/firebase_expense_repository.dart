import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/app_user.dart';
import '../models/expense_model.dart';
import '../models/group_model.dart';
import 'expense_repository.dart';

class FirebaseExpenseRepository implements ExpenseRepository {
  FirebaseExpenseRepository() {
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    FirebaseMessaging.instance.requestPermission();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    await _firestore.collection('expenses').doc(expense.id).set({
      'amount': expense.amount,
      'paidBy': expense.paidBy,
      'groupId': expense.groupId,
      'title': expense.title,
      'category': expense.category,
      'timestamp': expense.timestamp.toIso8601String(),
      'splitType': expense.splitType.name,
      'note': expense.note,
      'receiptPath': expense.receiptPath,
      'splitBetween': expense.shares
          .map(
            (share) => {
              'userId': share.userId,
              'amount': share.amount,
              'percentage': share.percentage,
            },
          )
          .toList(),
    });
  }

  @override
  Future<void> addGroup(GroupModel group) async {
    await _firestore.collection('groups').doc(group.id).set({
      'name': group.name,
      'icon': group.icon,
      'memberIds': group.memberIds,
      'createdBy': group.createdBy,
    });
  }

  @override
  Future<List<ExpenseModel>> fetchExpenses(String groupId) async {
    final snapshot = await _firestore
        .collection('expenses')
        .where('groupId', isEqualTo: groupId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ExpenseModel(
        id: doc.id,
        groupId: data['groupId'] as String,
        amount: (data['amount'] as num).toDouble(),
        paidBy: data['paidBy'] as String,
        title: data['title'] as String,
        category: data['category'] as String,
        shares: (data['splitBetween'] as List<dynamic>)
            .map(
              (item) => ExpenseShare(
                userId: item['userId'] as String,
                amount: (item['amount'] as num).toDouble(),
                percentage: (item['percentage'] as num?)?.toDouble(),
              ),
            )
            .toList(),
        timestamp: DateTime.parse(data['timestamp'] as String),
        splitType: SplitType.values.byName(data['splitType'] as String),
        note: data['note'] as String?,
        receiptPath: data['receiptPath'] as String?,
      );
    }).toList();
  }

  @override
  Future<List<GroupModel>> fetchGroups(String userId) async {
    final snapshot = await _firestore
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .get();

    return snapshot.docs
        .map(
          (doc) => GroupModel(
            id: doc.id,
            name: doc['name'] as String,
            icon: doc['icon'] as String,
            memberIds: List<String>.from(doc['memberIds'] as List<dynamic>),
            createdBy: doc['createdBy'] as String,
          ),
        )
        .toList();
  }

  @override
  Future<List<AppUser>> fetchUsers(String groupId) async {
    final groupDoc = await _firestore.collection('groups').doc(groupId).get();
    final memberIds = List<String>.from(groupDoc['memberIds'] as List<dynamic>);
    final usersSnapshot = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: memberIds)
        .get();

    return usersSnapshot.docs
        .map(
          (doc) => AppUser(
            id: doc.id,
            name: doc['name'] as String,
            email: doc['email'] as String,
            avatarUrl: doc['avatarUrl'] as String? ?? '',
          ),
        )
        .toList();
  }

  @override
  Future<void> updateGroup(GroupModel group) async {
    await _firestore.collection('groups').doc(group.id).update({
      'name': group.name,
      'icon': group.icon,
      'memberIds': group.memberIds,
    });
  }
}

