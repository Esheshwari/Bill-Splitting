import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/group_model.dart';
import '../../providers/app_provider.dart';

class EditGroupScreen extends StatefulWidget {
  const EditGroupScreen({
    super.key,
    required this.group,
  });

  final GroupModel group;

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  late final TextEditingController _nameController;
  late String _icon;
  late Set<String> _memberIds;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);
    _icon = widget.group.icon;
    _memberIds = widget.group.memberIds.toSet();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final knownUsers = <String, AppUser>{};
    for (final users in app.groupUsers.values) {
      for (final user in users) {
        knownUsers[user.id] = user;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit group')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Group name'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _icon,
                    items: const [
                      DropdownMenuItem(value: 'beach_access', child: Text('Trip')),
                      DropdownMenuItem(value: 'home', child: Text('Home')),
                      DropdownMenuItem(value: 'celebration', child: Text('Party')),
                    ],
                    onChanged: (value) => setState(() => _icon = value ?? _icon),
                    decoration: const InputDecoration(labelText: 'Group type'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: knownUsers.values.map((user) {
                  final selected = _memberIds.contains(user.id);
                  return FilterChip(
                    label: Text(user.name),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        if (selected) {
                          _memberIds.remove(user.id);
                        } else {
                          _memberIds.add(user.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () async {
              await app.updateGroup(
                GroupModel(
                  id: widget.group.id,
                  name: _nameController.text.trim(),
                  icon: _icon,
                  memberIds: _memberIds.toList(),
                  createdBy: widget.group.createdBy,
                ),
              );
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
  }
}
