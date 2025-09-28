import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class AIService {
  // For web, no TFLite, only mock detections

  Future<void> loadTFLiteModel(String modelPath) async {
    // No-op for web
  }

  // Process image with mock detections for web
  Future<List<Map<String, dynamic>>> detectObjects(Uint8List imageBytes) async {
    // Mock detections for web (environmental app: tree, person, car)
    return [
      {
        'x': 100.0,
        'y': 150.0,
        'width': 200.0,
        'height': 300.0,
        'score': 0.85,
        'class': 'tree',
      },
      {
        'x': 400.0,
        'y': 200.0,
        'width': 100.0,
        'height': 250.0,
        'score': 0.72,
        'class': 'person',
      },
    ];
  }

  void dispose() {
    // No-op for web
  }
}
