class GroupModel {
  const GroupModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.memberIds,
    required this.createdBy,
  });

  final String id;
  final String name;
  final String icon;
  final List<String> memberIds;
  final String createdBy;
}

