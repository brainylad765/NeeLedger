import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class AIService {
  Interpreter? _interpreter;

  // For TFLite
  Future<void> loadTFLiteModel(String modelPath) async {
    _interpreter = await Interpreter.fromAsset(modelPath);
  }

  // Process image with YOLOv8 (simplified example using TFLite)
  Future<List<Map<String, dynamic>>> detectObjects(Uint8List imageBytes) async {
    if (kIsWeb) {
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
    if (_interpreter != null) {
      // TFLite inference
      final inputImage = img.decodeImage(imageBytes);
      if (inputImage == null) return [];

      // Preprocess image (resize to 640x640, normalize, etc.)
      final resized = img.copyResize(inputImage, width: 640, height: 640);
      final input = _preprocessImage(resized);

      // Create output tensor shape [1, 84, 8400] for YOLOv8
      final outputShape = [1, 84, 8400];
      final output = List.generate(
        outputShape[0],
        (_) => List.generate(
          outputShape[1],
          (_) => List.generate(outputShape[2], (_) => 0.0),
        ),
      );

      _interpreter!.run(input, output);

      // Post-process TFLite output
      return _postProcessTFLiteOutput(output);
    }
    return [];
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Convert to RGB, normalize to 0-1, shape [1, 640, 640, 3] for NHWC
    final width = image.width;
    final height = image.height;
    final input = List.generate(
      1,
      (_) => List.generate(
        height,
        (y) => List.generate(width, (x) {
          final pixel = image.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    );
    return input;
  }

  List<Map<String, dynamic>> _postProcessOutput(
    List<List<List<double>>> output,
  ) {
    // Simplified post-processing for YOLOv8
    final detections = <Map<String, dynamic>>[];
    // Parse output tensor to get bounding boxes, classes, scores
    // This is a placeholder; actual implementation depends on model output format
    for (final detection in output[0]) {
      if (detection.length >= 6) {
        final x = detection[0];
        final y = detection[1];
        final w = detection[2];
        final h = detection[3];
        final score = detection[4];
        final classId = detection[5].toInt();
        if (score > 0.5) {
          // Confidence threshold
          detections.add({
            'x': x,
            'y': y,
            'width': w,
            'height': h,
            'score': score,
            'class': classId,
          });
        }
      }
    }
    return detections;
  }

  List<Map<String, dynamic>> _postProcessTFLiteOutput(List output) {
    // YOLOv8 post-processing: output[0][84][8400], where 84 = 4 bbox + 80 classes
    final detections = <Map<String, dynamic>>[];
    const cocoClasses = [
      'person',
      'bicycle',
      'car',
      'motorcycle',
      'airplane',
      'bus',
      'train',
      'truck',
      'boat',
      'traffic light',
      'fire hydrant',
      'stop sign',
      'parking meter',
      'bench',
      'bird',
      'cat',
      'dog',
      'horse',
      'sheep',
      'cow',
      'elephant',
      'bear',
      'zebra',
      'giraffe',
      'backpack',
      'umbrella',
      'handbag',
      'tie',
      'suitcase',
      'frisbee',
      'skis',
      'snowboard',
      'sports ball',
      'kite',
      'baseball bat',
      'baseball glove',
      'skateboard',
      'surfboard',
      'tennis racket',
      'bottle',
      'wine glass',
      'cup',
      'fork',
      'knife',
      'spoon',
      'bowl',
      'banana',
      'apple',
      'sandwich',
      'orange',
      'broccoli',
      'carrot',
      'hot dog',
      'pizza',
      'donut',
      'cake',
      'chair',
      'couch',
      'potted plant',
      'bed',
      'dining table',
      'toilet',
      'tv',
      'laptop',
      'mouse',
      'remote',
      'keyboard',
      'cell phone',
      'microwave',
      'oven',
      'toaster',
      'sink',
      'refrigerator',
      'book',
      'clock',
      'vase',
      'scissors',
      'teddy bear',
      'hair drier',
      'toothbrush',
    ];
    for (int i = 0; i < 8400; i++) {
      final bbox = [
        output[0][0][i],
        output[0][1][i],
        output[0][2][i],
        output[0][3][i],
      ]; // cx, cy, w, h
      double maxScore = 0.0;
      int maxClass = 0;
      for (int c = 0; c < 80; c++) {
        final score = output[0][4 + c][i];
        if (score > maxScore) {
          maxScore = score;
          maxClass = c;
        }
      }
      if (maxScore > 0.5) {
        final cx = bbox[0];
        final cy = bbox[1];
        final w = bbox[2];
        final h = bbox[3];
        detections.add({
          'x': cx - w / 2,
          'y': cy - h / 2,
          'width': w,
          'height': h,
          'score': maxScore,
          'class': cocoClasses[maxClass],
        });
      }
    }
    // Simple NMS: sort by score, remove overlapping >0.5 IoU
    detections.sort((a, b) => b['score'].compareTo(a['score']));
    final filtered = <Map<String, dynamic>>[];
    for (final det in detections) {
      bool keep = true;
      for (final f in filtered) {
        if (_iou(det, f) > 0.5) {
          keep = false;
          break;
        }
      }
      if (keep) filtered.add(det);
    }
    return filtered;
  }

  double _iou(Map<String, dynamic> box1, Map<String, dynamic> box2) {
    final x1 = box1['x'];
    final y1 = box1['y'];
    final w1 = box1['width'];
    final h1 = box1['height'];
    final x2 = box2['x'];
    final y2 = box2['y'];
    final w2 = box2['width'];
    final h2 = box2['height'];
    final xi1 = x1 > x2 ? x1 : x2;
    final yi1 = y1 > y2 ? y1 : y2;
    final xi2 = (x1 + w1) < (x2 + w2) ? (x1 + w1) : (x2 + w2);
    final yi2 = (y1 + h1) < (y2 + h2) ? (y1 + h1) : (y2 + h2);
    final interW = xi2 - xi1;
    final interH = yi2 - yi1;
    final interArea = interW > 0 && interH > 0 ? interW * interH : 0;
    final unionArea = w1 * h1 + w2 * h2 - interArea;
    return unionArea > 0 ? interArea / unionArea : 0;
  }

  void dispose() {
    _interpreter?.close();
  }
}
