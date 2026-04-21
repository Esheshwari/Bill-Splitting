import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_formatters.dart';
import '../../models/app_user.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/avatar_stack.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gradient_shell.dart';
import '../../widgets/summary_card.dart';
import '../balance/balance_summary_screen.dart';
import '../group/group_detail_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app = context.watch<AppProvider>();
    final summary = app.dashboardSummary();

    return Scaffold(
      body: GradientShell(
        child: SafeArea(
          child: app.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: app.loadGroups,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  auth.user?.name ?? 'Friend',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                            },
                            icon: CircleAvatar(
                              radius: 16,
                              child: Text((auth.user?.name ?? 'S').substring(0, 1)),
                            ),
                          ),
                          IconButton(
                            onPressed: auth.toggleTheme,
                            icon: const Icon(Icons.dark_mode_rounded),
                          ),
                          IconButton(
                            onPressed: auth.signOut,
                            icon: const Icon(Icons.logout_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 140,
                        child: Row(
                          children: [
                            Expanded(
                              child: SummaryCard(
                                title: 'You owe',
                                amount: AppFormatters.money(summary.totalOwed),
                                color: Colors.orange,
                                icon: Icons.arrow_upward_rounded,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: SummaryCard(
                                title: 'You get back',
                                amount: AppFormatters.money(summary.totalToReceive),
                                color: Colors.green,
                                icon: Icons.arrow_downward_rounded,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15),
                      const SizedBox(height: 18),
                      Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(18),
                          title: const Text('Smart suggestion'),
                          subtitle: Text(app.smartSuggestion()),
                          trailing: const Icon(Icons.auto_awesome_rounded),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Your groups',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const BalanceSummaryScreen(),
                                ),
                              );
                            },
                            child: const Text('Balances'),
                          ),
                          IconButton(
                            onPressed: () => _showCreateGroupSheet(context, app),
                            icon: const Icon(Icons.add_circle_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (app.groups.isEmpty)
                        const EmptyState(
                          title: 'No groups yet',
                          subtitle: 'Create your first trip, home, or party split.',
                          icon: Icons.groups_rounded,
                        )
                      else
                        ...app.groups.map((group) {
                          final users = app.usersForGroup(group.id);
                          final expenses = app.expensesForGroup(group.id);
                          final total = expenses.fold<double>(0, (sum, item) => sum + item.amount);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(18),
                                leading: CircleAvatar(
                                  radius: 26,
                                  child: Icon(_iconFromName(group.icon)),
                                ),
                                title: Text(group.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    AvatarStack(users: users),
                                    const SizedBox(height: 8),
                                    Text('${users.length} members - ${AppFormatters.money(total)} spent'),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right_rounded),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => GroupDetailScreen(group: group),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'home':
        return Icons.home_rounded;
      case 'celebration':
        return Icons.celebration_rounded;
      default:
        return Icons.beach_access_rounded;
    }
  }

  Future<void> _showCreateGroupSheet(BuildContext context, AppProvider app) async {
    final nameController = TextEditingController();
    String icon = 'beach_access';
    final selectedMembers = <String>{app.currentUserId};

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final dedupedUsers = <String, AppUser>{};
        for (final users in app.groupUsers.values) {
          for (final user in users) {
            dedupedUsers[user.id] = user;
          }
        }
        final allUsers = dedupedUsers.values.toList();

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Group name'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: icon,
                    items: const [
                      DropdownMenuItem(value: 'beach_access', child: Text('Trip')),
                      DropdownMenuItem(value: 'home', child: Text('Home')),
                      DropdownMenuItem(value: 'celebration', child: Text('Party')),
                    ],
                    onChanged: (value) => setModalState(() => icon = value ?? 'beach_access'),
                    decoration: const InputDecoration(labelText: 'Group type'),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    children: allUsers.map((user) {
                      final selected = selectedMembers.contains(user.id);
                      return FilterChip(
                        label: Text(user.name),
                        selected: selected,
                        onSelected: (_) {
                          setModalState(() {
                            if (selected) {
                              selectedMembers.remove(user.id);
                            } else {
                              selectedMembers.add(user.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        await app.addGroup(
                          name: nameController.text.trim(),
                          icon: icon,
                          memberIds: selectedMembers.toList(),
                        );
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      child: const Text('Create group'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
