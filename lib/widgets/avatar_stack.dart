import 'package:flutter/material.dart';

import '../models/app_user.dart';

class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.users,
  });

  final List<AppUser> users;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Stack(
        children: List.generate(users.take(4).length, (index) {
          final user = users[index];
          return Positioned(
            left: index * 20,
            child: CircleAvatar(
              radius: 14,
              child: Text(user.name.substring(0, 1)),
            ),
          );
        }),
      ),
    );
  }
}

