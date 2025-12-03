class LeaderboardEntry {
  final String duoId;
  final String duoName;
  final List<String> members;
  final int totalPoints;
  final DateTime updatedAt;

  const LeaderboardEntry({
    required this.duoId,
    required this.duoName,
    required this.members,
    required this.totalPoints,
    required this.updatedAt,
  });
}
