class Evidence {
  final String id;
  final String filePath;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  final List<Map<String, dynamic>>? detections;

  Evidence({
    required this.id,
    required this.filePath,
    this.latitude,
    this.longitude,
    DateTime? timestamp,
    this.detections,
  }) : timestamp = timestamp ?? DateTime.now();
}
