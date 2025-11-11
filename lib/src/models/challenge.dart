import 'package:cloud_firestore/cloud_firestore.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final int maxPoints;
  final Map<String, int> points;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.maxPoints,
    required this.points,
  });

  factory Challenge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Challenge(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      maxPoints: data['max_points'] ?? 0,
      points: Map<String, int>.from(data['points'] ?? {}),
    );
  }

  factory Challenge.fromMap(Map<String, dynamic> data, String id) {
    return Challenge(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      maxPoints: data['maxPoints'] ?? 0,
      points: Map<String, int>.from(data['points'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'max_points': maxPoints,
      'points': points,
    };
  }
}
