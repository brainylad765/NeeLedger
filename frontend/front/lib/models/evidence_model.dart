class Evidence {
  final String id;
  final String filePath;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;

  Evidence({
    required this.id,
    required this.filePath,
    this.latitude,
    this.longitude,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
