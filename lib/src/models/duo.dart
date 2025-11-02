import 'package:cloud_firestore/cloud_firestore.dart';

class DuoParticipant {
  final String id;
  final String name;

  const DuoParticipant({
    required this.id,
    required this.name,
  });

  factory DuoParticipant.fromMap(Map<String, dynamic> map) {
    return DuoParticipant(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuoParticipant &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class Duo {
  final String id;
  final List<DuoParticipant> participants;
  final String name;
  final String inviteCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int maxParticipants;

  const Duo({
    required this.id,
    required this.participants,
    required this.name,
    required this.inviteCode,
    required this.createdAt,
    required this.updatedAt,
    this.maxParticipants = 2,
  });

  // Factory constructor para criar um Duo a partir do Firestore
  factory Duo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Duo(
      id: doc.reference.parent.parent?.id ?? '',
      participants: (data['participants'] as List?)
              ?.map((e) => DuoParticipant.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      name: data['name'] ?? '',
      inviteCode: data['inviteCode'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      maxParticipants: data['maxParticipants'] ?? 10,
    );
  }

  // Factory constructor para criar um Duo a partir de um Map
  factory Duo.fromMap(Map<String, dynamic> data, String id) {
    return Duo(
      id: id,
      participants: (data['participants'] as List?)
              ?.map((e) => DuoParticipant.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      name: data['name'] ?? '',
      inviteCode: data['inviteCode'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      maxParticipants: data['maxParticipants'] ?? 2,
    );
  }

  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'participants': participants.map((e) => e.toMap()).toList(),
      'name': name,
      'inviteCode': inviteCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'maxParticipants': maxParticipants,
    };
  }

  // Cópia com modificações
  Duo copyWith({
    String? id,
    List<DuoParticipant>? participants,
    String? name,
    String? inviteCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? maxParticipants,
  }) {
    return Duo(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      name: name ?? this.name,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      maxParticipants: maxParticipants ?? this.maxParticipants,
    );
  }

  // Verificar se o usuário é participante
  bool isParticipant(String userId) => participants.any((p) => p.id == userId);

  // Verificar se o usuário é membro (dono ou participante)
  bool isMember(String userId) => isParticipant(userId);

  // Verificar se o duo está cheio
  bool get isFull => participants.length >= maxParticipants;

  // Obter total de membros (incluindo o dono)
  int get totalMembers => participants.length;

  @override
  String toString() {
    return 'Duo{id: $id, name: $name, participants: $participants, inviteCode: $inviteCode}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Duo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
