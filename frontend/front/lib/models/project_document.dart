class ProjectDocument {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String fileUrl;
  final String fileName;
  final int fileSize;
  final String? fileType;
  final String projectType;
  final String status;
  final String? location;
  final int carbonCredits;
  final double investmentAmount;
  final double progress;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectDocument({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.fileUrl,
    required this.fileName,
    required this.fileSize,
    this.fileType,
    required this.projectType,
    required this.status,
    this.location,
    required this.carbonCredits,
    required this.investmentAmount,
    required this.progress,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectDocument.fromMap(Map<String, dynamic> map) {
    return ProjectDocument(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      fileUrl: map['file_url'] as String,
      fileName: map['file_name'] as String,
      fileSize: map['file_size'] as int,
      fileType: map['file_type'] as String?,
      projectType: map['project_type'] as String? ?? 'general',
      status: map['status'] as String? ?? 'active',
      location: map['location'] as String?,
      carbonCredits: map['carbon_credits'] as int? ?? 0,
      investmentAmount: (map['investment_amount'] as num?)?.toDouble() ?? 0.0,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'file_type': fileType,
      'project_type': projectType,
      'status': status,
      'location': location,
      'carbon_credits': carbonCredits,
      'investment_amount': investmentAmount,
      'progress': progress,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProjectDocument copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? fileType,
    String? projectType,
    String? status,
    String? location,
    int? carbonCredits,
    double? investmentAmount,
    double? progress,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectDocument(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      projectType: projectType ?? this.projectType,
      status: status ?? this.status,
      location: location ?? this.location,
      carbonCredits: carbonCredits ?? this.carbonCredits,
      investmentAmount: investmentAmount ?? this.investmentAmount,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  String get formattedFileSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return '#4CAF50'; // Green
      case 'pending':
        return '#FF9800'; // Orange
      case 'completed':
        return '#2196F3'; // Blue
      case 'archived':
        return '#9E9E9E'; // Grey
      default:
        return '#9E9E9E';
    }
  }

  String get progressPercentage {
    return '${(progress * 100).toStringAsFixed(1)}%';
  }

  String get formattedInvestment {
    if (investmentAmount < 1000) return '\$${investmentAmount.toStringAsFixed(2)}';
    if (investmentAmount < 1000000) return '\$${(investmentAmount / 1000).toStringAsFixed(1)}K';
    return '\$${(investmentAmount / 1000000).toStringAsFixed(1)}M';
  }

  String get formattedCredits {
    if (carbonCredits < 1000) return '$carbonCredits';
    if (carbonCredits < 1000000) return '${(carbonCredits / 1000).toStringAsFixed(1)}K';
    return '${(carbonCredits / 1000000).toStringAsFixed(1)}M';
  }

  bool get isExpired {
    return endDate != null && endDate!.isBefore(DateTime.now());
  }

  bool get isUpcoming {
    return startDate != null && startDate!.isAfter(DateTime.now());
  }

  int get daysRemaining {
    if (endDate == null) return -1;
    return endDate!.difference(DateTime.now()).inDays;
  }

  @override
  String toString() {
    return 'ProjectDocument{id: $id, title: $title, status: $status, progress: $progressPercentage}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectDocument &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}