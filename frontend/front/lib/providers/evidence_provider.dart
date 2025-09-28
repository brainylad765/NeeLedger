import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/evidence_model.dart';
import '../services/ai_service_mobile.dart'
    if (dart.library.html) '../services/ai_service_web.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

// Optional: set this to your XAI analysis endpoint. If null or empty, the provider uses a mocked report.
const String? xaiApiUrl = null; // e.g. 'https://example.com/analyze'

class EvidenceProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final List<Evidence> _items = [];
  final AIService _aiService = AIService();
  bool _isUploading = false;
  String? _uploadError;

  List<Evidence> get items => List.unmodifiable(_items);
  bool get isUploading => _isUploading;
  String? get uploadError => _uploadError;

  EvidenceProvider() {
    // Load AI model if not web
    if (!kIsWeb) {
      _aiService.loadTFLiteModel('assets/models/yolov8n.tflite');
    }
    _listenToEvidence();
  }

  void _listenToEvidence() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Real-time subscription to evidence table
    final subscription = _supabase
        .channel('evidence')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'evidence',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            _fetchEvidence(); // Refresh on change
          },
        )
        .subscribe();

    // Initial fetch
    _fetchEvidence();
  }

  Future<void> _fetchEvidence() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase
          .from('evidence')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);

      _items.clear();
      for (final json in response) {
        _items.add(Evidence.fromJson(json));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching evidence: $e');
    }
  }

  Future<void> addEvidence(
    String filePath, {
    double? lat,
    double? lon,
    Uint8List? webFileBytes,
  }) async {
    _isUploading = true;
    _uploadError = null;
    notifyListeners();

    try {
      String downloadURL;
      final fileName = '${const Uuid().v4()}_${path.basename(filePath)}';
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      List<Map<String, dynamic>> detections = [];
      Uint8List uploadBytes;
      if (kIsWeb && webFileBytes != null) {
        // For web, use the provided file bytes
        detections = await _aiService.detectObjects(webFileBytes);
        uploadBytes = webFileBytes;
      } else if (kIsWeb) {
        // Fallback: try to get bytes from blob URL
        try {
          final response = await http.get(Uri.parse(filePath));
          final bytes = response.bodyBytes;
          detections = await _aiService.detectObjects(bytes);
          uploadBytes = bytes;
        } catch (e) {
          throw Exception('Failed to read web file: $e');
        }
      } else {
        // For mobile platforms, read the file and upload
        final file = File(filePath);
        final bytes = await file.readAsBytes();

        // Detect objects before enhancement
        if (!kIsWeb) {
          detections = await _aiService.detectObjects(bytes);
        }

        // Process image with OpenCV (only for mobile)
        uploadBytes = bytes;
        if (!kIsWeb) {
          uploadBytes = await _enhanceImage(bytes);
        }
      }

      // Upload to Supabase Storage
      if (kIsWeb) {
        await _supabase.storage
            .from('evidence')
            .uploadBinary(fileName, uploadBytes);
      } else {
        final file = File(filePath);
        await _supabase.storage.from('evidence').upload(fileName, file);
      }
      downloadURL = _supabase.storage.from('evidence').getPublicUrl(fileName);

      // Save evidence metadata to Supabase
      final evidenceData = {
        'id': const Uuid().v4(),
        'user_id': userId,
        'file_path': downloadURL,
        'latitude': lat,
        'longitude': lon,
        'timestamp': DateTime.now().toIso8601String(),
        'detections': detections,
      };
      await _supabase.from('evidence').insert(evidenceData);

      // Add to local list for immediate display
      final ev = Evidence.fromJson(evidenceData);
      _items.insert(0, ev);

      debugPrint('✅ Evidence uploaded to Supabase successfully!');
    } catch (e) {
      _uploadError = e.toString();
      debugPrint('❌ Error uploading evidence to Supabase: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void clearError() {
    _uploadError = null;
    notifyListeners();
  }

  Future<void> addPdfEvidence({
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    _isUploading = true;
    _uploadError = null;
    notifyListeners();

    try {
      final uniqueFileName = '${const Uuid().v4()}_$fileName';
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Upload to Supabase Storage
      await _supabase.storage
          .from('evidence')
          .uploadBinary(uniqueFileName, fileBytes);
      final downloadURL = _supabase.storage
          .from('evidence')
          .getPublicUrl(uniqueFileName);

      // Save evidence metadata to Supabase
      final evidenceData = {
        'id': const Uuid().v4(),
        'user_id': userId,
        'file_path': downloadURL,
        'latitude': null,
        'longitude': null,
        'timestamp': DateTime.now().toIso8601String(),
        'detections': null,
      };
      await _supabase.from('evidence').insert(evidenceData);

      // Add to local list for immediate display
      final ev = Evidence.fromJson(evidenceData);
      _items.insert(0, ev);

      debugPrint('✅ PDF evidence uploaded to Supabase successfully!');
    } catch (e) {
      _uploadError = e.toString();
      debugPrint('❌ Error uploading PDF evidence to Supabase: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Mock XAI analysis: In real app this would call a backend or ML model.
  Future<String> generateXAIReport(Evidence e) async {
    // If an XAI API is configured, attempt to call it with the file and metadata.
    if (xaiApiUrl != null && xaiApiUrl!.isNotEmpty) {
      try {
        final uri = Uri.parse(xaiApiUrl!);
        // If file exists we send as multipart; otherwise send JSON metadata only.
        if (File(e.filePath).existsSync()) {
          final request = http.MultipartRequest('POST', uri);
          request.fields['id'] = e.id;
          if (e.latitude != null) {
            request.fields['latitude'] = e.latitude!.toString();
          }
          if (e.longitude != null) {
            request.fields['longitude'] = e.longitude!.toString();
          }
          request.files.add(
            await http.MultipartFile.fromPath('file', e.filePath),
          );
          final streamed = await request.send();
          final resp = await http.Response.fromStream(streamed);
          if (resp.statusCode == 200) return resp.body;
          return 'XAI service returned ${resp.statusCode}: ${resp.body}';
        } else {
          final resp = await http.post(
            uri,
            body: {
              'id': e.id,
              'latitude': e.latitude?.toString() ?? '',
              'longitude': e.longitude?.toString() ?? '',
              'filename': kIsWeb
                  ? e.filePath.split('/').last
                  : path.basename(e.filePath),
            },
          );
          if (resp.statusCode == 200) return resp.body;
          return 'XAI service returned ${resp.statusCode}: ${resp.body}';
        }
      } catch (err) {
        return 'XAI call failed: $err';
      }
    }

    // Fallback: mocked local report
    await Future.delayed(const Duration(seconds: 1));
    final buffer = StringBuffer();
    buffer.writeln('Report for evidence ${e.id}');
    if (e.latitude != null && e.longitude != null) {
      buffer.writeln(
        'Location: ${e.latitude!.toStringAsFixed(5)}, ${e.longitude!.toStringAsFixed(5)}',
      );
    } else {
      buffer.writeln('Location: not provided');
    }
    buffer.writeln(
      'File: ${kIsWeb ? e.filePath.split('/').last : path.basename(e.filePath)}',
    );
    if (e.detections != null && e.detections!.isNotEmpty) {
      final detectionStrings = e.detections!.map(
        (d) => '${d['label']} (${d['confidence'].toStringAsFixed(2)})',
      );
      buffer.writeln('Detected objects: ${detectionStrings.join(', ')}');
    }
    buffer.writeln(
      'Likely contents: Vegetation cover, shoreline, photo metadata consistent.',
    );
    buffer.writeln('Confidence: 78%');
    buffer.writeln(
      'Suggested actions: verify geo-tagging, provide additional photos from different angles.',
    );
    return buffer.toString();
  }

  Future<Uint8List> _enhanceImage(Uint8List bytes) async {
    try {
      // Decode image using image package (mocking OpenCV functionality)
      final image = img.decodeImage(bytes);
      if (image == null) return bytes;

      // Apply simple image processing (e.g., grayscale and blur to simulate enhancement)
      final gray = img.grayscale(image);
      final enhanced = img.gaussianBlur(gray, radius: 2);

      // Encode back to bytes
      return Uint8List.fromList(img.encodeJpg(enhanced));
    } catch (e) {
      debugPrint('Image processing failed: $e');
      return bytes; // Return original if processing fails
    }
  }
}
