import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // Supabase integration
  final SupabaseClient _supabase = Supabase.instance.client;
  final List<Map<String, dynamic>> _supabaseDocuments = [];
  bool _isSupabaseEnabled = true;
  bool _isSupabaseUploading = false;
  String? _supabaseError;

  // Local getters (temporary, cleared on hot reload)
  List<PdfMeta> get pdfs => List.unmodifiable(_pdfs);
  List<String> get projects => List.unmodifiable(_projects);
  List<ImageUpload> get images => List.unmodifiable(_images);
  bool get hasUploads => _pdfs.isNotEmpty || _images.isNotEmpty;
  bool get hasInitialUploads => _hasInitialUploads;
  int get totalUploads => _totalUploads;
  bool get isCaptureLimitReached => _images.length >= 5;

  // Supabase getters (persistent storage)
  List<Map<String, dynamic>> get supabaseDocuments =>
      List.unmodifiable(_supabaseDocuments);
  bool get isSupabaseEnabled => _isSupabaseEnabled;
  bool get isSupabaseUploading => _isSupabaseUploading;
  String? get supabaseError => _supabaseError;
  bool get hasSupabaseUploads => _supabaseDocuments.isNotEmpty;

  Future<void> addPdf(PlatformFile file) async {
    try {
      final pdf = PdfMeta(
        id: _uuid.v4(),
        name: file.name,
        size: file.size,
        timestamp: DateTime.now(),
      );

      // Add to local storage (temporary)
      _pdfs.add(pdf);
      _projects.add(file.name); // Text-only project from PDF name
      _totalUploads++;

      // Mark as having initial uploads if this is the first upload
      if (!_hasInitialUploads) {
        _hasInitialUploads = true;
      }

      // Parallel upload to Supabase (persistent)
      if (_isSupabaseEnabled && file.bytes != null) {
        await _uploadPdfToSupabase(file, pdf.id);
        // Create project in Supabase
        await _createProject(
          name: 'Project from ${file.name}',
          type: 'Document',
          description: 'Uploaded PDF document',
        );
      }

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

      // Add to local storage (temporary)
      _images.add(image);
      _totalUploads++;

      // Mark as having initial uploads if this is the first upload
      if (!_hasInitialUploads) {
        _hasInitialUploads = true;
      }

      notifyListeners();

      // Mock upload progress for local
      await _simulateUpload(image.id);

      // Parallel upload to Supabase (persistent)
      if (_isSupabaseEnabled) {
        await _uploadImageToSupabase(imageFile, image.id, lat, lng);
        // Create project in Supabase
        await _createProject(
          name: 'Project from image ${imageFile.path.split('/').last}',
          type: 'Image',
          description: 'Captured image evidence',
          location: lat != null && lng != null ? '$lat, $lng' : null,
        );
      }
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

  // Supabase upload methods
  Future<void> _uploadPdfToSupabase(PlatformFile file, String localId) async {
    if (file.bytes == null) return;

    _isSupabaseUploading = true;
    _supabaseError = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Upload to Supabase Storage
      final fileName = '${_uuid.v4()}_${file.name}';
      await _supabase.storage
          .from('documents')
          .uploadBinary(fileName, file.bytes!);

      final publicUrl = _supabase.storage
          .from('documents')
          .getPublicUrl(fileName);

      // Save metadata to documents table
      final documentData = {
        'id': _uuid.v4(),
        'user_id': userId,
        'local_id': localId,
        'file_name': file.name,
        'file_url': publicUrl,
        'file_size': file.size,
        'file_type': 'pdf',
        'upload_timestamp': DateTime.now().toIso8601String(),
        'metadata': {'original_name': file.name, 'local_reference': localId},
      };

      await _supabase.from('documents').insert(documentData);

      // Add to local Supabase documents list
      _supabaseDocuments.add(documentData);

      debugPrint('✅ PDF uploaded to Supabase successfully: ${file.name}');
    } catch (e) {
      _supabaseError = 'Failed to upload PDF to Supabase: $e';
      debugPrint('❌ Supabase PDF upload error: $e');
    } finally {
      _isSupabaseUploading = false;
      notifyListeners();
    }
  }

  Future<void> _uploadImageToSupabase(
    File imageFile,
    String localId,
    double? lat,
    double? lng,
  ) async {
    _isSupabaseUploading = true;
    _supabaseError = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Upload to Supabase Storage
      final fileName = '${_uuid.v4()}_${imageFile.path.split('/').last}';
      await _supabase.storage.from('images').uploadBinary(fileName, imageBytes);

      final publicUrl = _supabase.storage.from('images').getPublicUrl(fileName);

      // Save metadata to documents table
      final documentData = {
        'id': _uuid.v4(),
        'user_id': userId,
        'local_id': localId,
        'file_name': imageFile.path.split('/').last,
        'file_url': publicUrl,
        'file_size': imageBytes.length,
        'file_type': 'image',
        'latitude': lat,
        'longitude': lng,
        'upload_timestamp': DateTime.now().toIso8601String(),
        'metadata': {
          'original_path': imageFile.path,
          'local_reference': localId,
          'gps_coordinates': lat != null && lng != null ? '$lat,$lng' : null,
        },
      };

      await _supabase.from('documents').insert(documentData);

      // Add to local Supabase documents list
      _supabaseDocuments.add(documentData);

      debugPrint(
        '✅ Image uploaded to Supabase successfully: ${imageFile.path}',
      );
    } catch (e) {
      _supabaseError = 'Failed to upload image to Supabase: $e';
      debugPrint('❌ Supabase image upload error: $e');
    } finally {
      _isSupabaseUploading = false;
      notifyListeners();
    }
  }

  // Supabase management methods
  Future<void> loadSupabaseDocuments() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('documents')
          .select()
          .eq('user_id', userId)
          .order('upload_timestamp', ascending: false);

      _supabaseDocuments.clear();
      _supabaseDocuments.addAll(response);
      notifyListeners();
    } catch (e) {
      _supabaseError = 'Failed to load Supabase documents: $e';
      debugPrint('❌ Error loading Supabase documents: $e');
      notifyListeners();
    }
  }

  Future<void> deleteSupabaseDocument(String documentId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Find the document
      final doc = _supabaseDocuments.firstWhere(
        (d) => d['id'] == documentId,
        orElse: () => {},
      );

      if (doc.isEmpty) {
        throw Exception('Document not found');
      }

      // Delete from storage
      final fileName = doc['file_url'].split('/').last;
      final bucket = doc['file_type'] == 'pdf' ? 'documents' : 'images';
      await _supabase.storage.from(bucket).remove([fileName]);

      // Delete from database
      await _supabase
          .from('documents')
          .delete()
          .eq('id', documentId)
          .eq('user_id', userId);

      // Remove from local list
      _supabaseDocuments.removeWhere((d) => d['id'] == documentId);
      notifyListeners();

      debugPrint('✅ Document deleted from Supabase: $documentId');
    } catch (e) {
      _supabaseError = 'Failed to delete document: $e';
      debugPrint('❌ Error deleting Supabase document: $e');
      notifyListeners();
    }
  }

  void toggleSupabaseIntegration(bool enabled) {
    _isSupabaseEnabled = enabled;
    notifyListeners();
  }

  void clearSupabaseError() {
    _supabaseError = null;
    notifyListeners();
  }

  // Initialize provider with Supabase data
  Future<void> initialize() async {
    await _ensureBucketsExist();
    await loadSupabaseDocuments();
  }

  // Ensure storage buckets exist
  Future<void> _ensureBucketsExist() async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      final bucketNames = buckets.map((b) => b.name).toSet();

      if (!bucketNames.contains('documents')) {
        debugPrint(
          '⚠️ Documents bucket not found. Please create it in Supabase dashboard.',
        );
        _supabaseError =
            'Documents bucket not found. Please run the SQL schema.';
        notifyListeners();
        return;
      }

      if (!bucketNames.contains('images')) {
        debugPrint(
          '⚠️ Images bucket not found. Please create it in Supabase dashboard.',
        );
        _supabaseError = 'Images bucket not found. Please run the SQL schema.';
        notifyListeners();
        return;
      }

      debugPrint('✅ Storage buckets verified: documents, images');
    } catch (e) {
      _supabaseError = 'Failed to verify storage buckets: $e';
      debugPrint('❌ Error checking storage buckets: $e');
      notifyListeners();
    }
  }

  // Manual bucket verification for debugging
  Future<Map<String, bool>> verifyBuckets() async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      final bucketNames = buckets.map((b) => b.name).toSet();

      return {
        'documents': bucketNames.contains('documents'),
        'images': bucketNames.contains('images'),
      };
    } catch (e) {
      debugPrint('❌ Error verifying buckets: $e');
      return {'documents': false, 'images': false};
    }
  }

  // Create project in Supabase Projects table
  Future<String> _createProject({
    required String name,
    String status = 'Planning',
    String? evidenceId,
    int carbonCredits = 0,
    int totalValue = 0,
    double progress = 0.0,
    String? location,
    String? type,
    String? description,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final projectData = {
        'id': _uuid.v4(),
        'user_id': userId,
        'account_id': 'ACC-DEFAULT',
        'name': name,
        'status': status,
        'evidence_id': evidenceId,
        'carbon_credits': carbonCredits,
        'credits_issued': 0,
        'total_value': totalValue,
        'progress': progress,
        'location': location,
        'type': type,
        'country': 'Unknown',
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase.from('projects').insert(projectData);
      if (response.isEmpty) {
        throw Exception('Failed to create project');
      }

      debugPrint('✅ Project created in Supabase: ${projectData['id']}');
      return projectData['id'] as String;
    } catch (e) {
      debugPrint('❌ Error creating project: $e');
      rethrow;
    }
  }
}
