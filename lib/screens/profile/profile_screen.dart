import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    child: Text((user?.name ?? 'S').substring(0, 1)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? 'SplitSmart User',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(user?.email ?? 'Not signed in'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: auth.themeMode == ThemeMode.dark,
                  onChanged: (_) => auth.toggleTheme(),
                  title: const Text('Dark mode'),
                  subtitle: const Text('Switch between light and dark themes'),
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text('Sign out'),
                  onTap: auth.signOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

