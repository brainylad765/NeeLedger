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

  factory Evidence.fromJson(Map<String, dynamic> json) {
    return Evidence(
      id: json['id'],
      filePath: json['file_path'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      detections: json['detections'] != null
          ? List<Map<String, dynamic>>.from(json['detections'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_path': filePath,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'detections': detections,
    };
  }
}
