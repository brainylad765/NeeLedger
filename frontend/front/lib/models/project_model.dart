import 'package:supabase_flutter/supabase_flutter.dart';

class Project {
  final String id;
  final String userId;
  final String name;
  final String status;
  final String? evidenceId;
  final int carbonCredits;
  final int totalValue;
  final double progress;
  final String? location;
  final String? type;
  final String? description;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.userId,
    required this.name,
    this.status = 'Planning',
    this.evidenceId,
    this.carbonCredits = 0,
    this.totalValue = 0,
    this.progress = 0.0,
    this.location,
    this.type,
    this.description,
    required this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is DateTime) return date;
      if (date is String) return DateTime.parse(date);
      return DateTime.now();
    }

    return Project(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? 'Planning',
      evidenceId: json['evidence_id'],
      carbonCredits: json['carbon_credits'] ?? 0,
      totalValue: json['total_value'] ?? 0,
      progress: (json['progress'] ?? 0.0).toDouble(),
      location: json['location'],
      type: json['type'],
      description: json['description'],
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'status': status,
      'evidence_id': evidenceId,
      'carbon_credits': carbonCredits,
      'total_value': totalValue,
      'progress': progress,
      'location': location,
      'type': type,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
