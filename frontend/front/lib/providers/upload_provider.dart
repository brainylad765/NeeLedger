import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PdfMeta {
  final String id;
  final String name;
  final int size;
  final DateTime timestamp;

  PdfMeta({
    required this.id,
    required this.name,
    required this.size,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'size': size,
    'timestamp': timestamp.toIso8601String(),
  };
}

class ImageUpload {
  final String id;
  final String path;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  double progress;
  String status;

  ImageUpload({
    required this.id,
    required this.path,
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.progress = 0.0,
    this.status = 'uploading',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
    'progress': progress,
    'status': status,
  };
}



class UploadProvider extends ChangeNotifier {
  final List<PdfMeta> _pdfs = [];
  final List<String> _projects = [];
  final List<ImageUpload> _images = [];
  final Uuid _uuid = const Uuid();
  bool _hasInitialUploads = false;
  int _totalUploads = 0;

  UploadProvider() {
    _loadFromPrefs();
  }

  // Local getters (temporary, cleared on hot reload)
  List<PdfMeta> get pdfs => List.unmodifiable(_pdfs);
  List<String> get projects => List.unmodifiable(_projects);
  List<ImageUpload> get images => List.unmodifiable(_images);
  bool get hasUploads => _pdfs.isNotEmpty || _images.isNotEmpty;
  bool get hasInitialUploads => _hasInitialUploads;
  int get totalUploads => _totalUploads;
  bool get isCaptureLimitReached => _images.length >= 5;

  Future<void> addPdf(PlatformFile file) async {
    try {
      final pdf = PdfMeta(
        id: _uuid.v4(),
        name: file.name,
        size: file.size,
        timestamp: DateTime.now(),
      );

      // Add to local storage (persistent)
      _pdfs.add(pdf);
      _projects.add(file.name); // Text-only project from PDF name
      _totalUploads++;

      // Mark as having initial uploads if this is the first upload
      if (!_hasInitialUploads) {
        _hasInitialUploads = true;
      }

      await _saveToPrefs();

      notifyListeners();
    } catch (e) {
      debugPrint('PDF Upload Error: $e');
      rethrow;
    }
  }

  Future<void> addImage(File imageFile, double? lat, double? lng) async {
    try {
      if (_images.length >= 5) {
        throw Exception('Maximum image upload limit reached (5/5)');
      }
      final image = ImageUpload(
        id: _uuid.v4(),
        path: imageFile.path,
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
      );

      // Add to local storage (persistent)
      _images.add(image);
      _totalUploads++;

      // Mark as having initial uploads if this is the first upload
      if (!_hasInitialUploads) {
        _hasInitialUploads = true;
      }

      await _saveToPrefs();

      notifyListeners();

      // Mock upload progress for local
      await _simulateUpload(image.id);
    } catch (e) {
      debugPrint('Image Upload Error: $e');
      rethrow;
    }
  }

  void removeImage(String id) {
    _images.removeWhere((img) => img.id == id);
    notifyListeners();
  }

  Future<void> _simulateUpload(String imageId) async {
    const totalSteps = 10;
    for (int i = 1; i <= totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      updateImageProgress(imageId, (i / totalSteps * 100).toInt());
    }
    // Set to complete
    final index = _images.indexWhere((img) => img.id == imageId);
    if (index != -1) {
      _images[index].status = 'completed';
      notifyListeners();
    }
  }

  void updateImageProgress(String imageId, int progress) {
    final index = _images.indexWhere((img) => img.id == imageId);
    if (index != -1) {
      _images[index].progress = progress.toDouble();
      notifyListeners();
    }
  }

  // Hook for YOLO/OpenCV processing (commented for future implementation)
  void processImageWithYOLO(File imageFile) {
    // TODO: Integrate YOLOv8 or OpenCV for image processing
    // Example: Call native channel or plugin for AI processing
    debugPrint('Processing image with YOLO: ${imageFile.path}');
  }

  void clearState() {
    _pdfs.clear();
    _projects.clear();
    _images.clear();
    _hasInitialUploads = false;
    _totalUploads = 0;
    _saveToPrefs();
    notifyListeners();
  }

  // Reset capture count for new session
  void resetCaptureSession() {
    _images.clear();
    notifyListeners();
  }

  // Check if this is the first project upload
  bool get isFirstProjectUpload => _totalUploads == 0;

  // Get upload statistics
  Map<String, int> get uploadStats => {
    'pdfs': _pdfs.length,
    'images': _images.length,
    'total': _totalUploads,
  };

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final pdfList = _pdfs.map((pdf) => jsonEncode(pdf.toJson())).toList();
    final imageList = _images.map((img) => jsonEncode(img.toJson())).toList();
    await prefs.setStringList('pdfs', pdfList);
    await prefs.setStringList('images', imageList);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final pdfList = prefs.getStringList('pdfs') ?? [];
    final imageList = prefs.getStringList('images') ?? [];

    _pdfs.clear();
    _images.clear();

    for (var pdfStr in pdfList) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(pdfStr);
        _pdfs.add(PdfMeta(
          id: jsonMap['id'] ?? '',
          name: jsonMap['name'] ?? 'Unknown',
          size: jsonMap['size'] ?? 0,
          timestamp: DateTime.parse(jsonMap['timestamp'] ?? DateTime.now().toIso8601String()),
        ));
      } catch (e) {
        debugPrint('Error decoding PDF from prefs: $e');
      }
    }

    for (var imgStr in imageList) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(imgStr);
        _images.add(ImageUpload(
          id: jsonMap['id'] ?? '',
          path: jsonMap['path'] ?? '',
          latitude: jsonMap['latitude'],
          longitude: jsonMap['longitude'],
          timestamp: DateTime.parse(jsonMap['timestamp'] ?? DateTime.now().toIso8601String()),
          progress: (jsonMap['progress'] ?? 100).toDouble(),
          status: jsonMap['status'] ?? 'completed',
        ));
      } catch (e) {
        debugPrint('Error decoding Image from prefs: $e');
      }
    }

    _hasInitialUploads = _pdfs.isNotEmpty || _images.isNotEmpty;
    _totalUploads = _pdfs.length + _images.length;

    notifyListeners();
  }
}
