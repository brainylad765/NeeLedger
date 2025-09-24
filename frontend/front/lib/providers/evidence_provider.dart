import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/evidence_model.dart';
import '../services/firebase_service.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';

// Optional: set this to your XAI analysis endpoint. If null or empty, the provider uses a mocked report.
const String? xaiApiUrl = null; // e.g. 'https://example.com/analyze'

class EvidenceProvider with ChangeNotifier {
  final List<Evidence> _items = [];
  final FirebaseService _firebaseService = FirebaseService();
  bool _isUploading = false;
  String? _uploadError;

  List<Evidence> get items => List.unmodifiable(_items);
  bool get isUploading => _isUploading;
  String? get uploadError => _uploadError;

  EvidenceProvider() {
    // Listen to real-time evidence updates from Firebase
    _firebaseService.listenToEvidence((evidenceList) {
      _items.clear();
      for (var evidenceData in evidenceList) {
        final evidence = Evidence(
          id: evidenceData['id'] ?? const Uuid().v4(),
          filePath: evidenceData['fileURLs']?.first ?? '',
          latitude: evidenceData['location']?['latitude']?.toDouble(),
          longitude: evidenceData['location']?['longitude']?.toDouble(),
          timestamp: evidenceData['createdAt']?.toDate() ?? DateTime.now(),
        );
        _items.add(evidence);
      }
      notifyListeners();
    });
  }

  Future<void> addEvidence(String filePath, {double? lat, double? lon, Uint8List? webFileBytes}) async {
    _isUploading = true;
    _uploadError = null;
    notifyListeners();

    try {
      String downloadURL;
      final fileName = '${const Uuid().v4()}_${path.basename(filePath)}';
      
      if (kIsWeb && webFileBytes != null) {
        // For web, use the provided file bytes
        final storageRef = FirebaseStorage.instance.ref().child('evidence/$fileName');
        await storageRef.putData(webFileBytes);
        downloadURL = await storageRef.getDownloadURL();
      } else if (kIsWeb) {
        // Fallback: try to get bytes from blob URL
        try {
          final response = await http.get(Uri.parse(filePath));
          final bytes = response.bodyBytes;
          
          final storageRef = FirebaseStorage.instance.ref().child('evidence/$fileName');
          await storageRef.putData(bytes);
          downloadURL = await storageRef.getDownloadURL();
        } catch (e) {
          throw Exception('Failed to read web file: $e');
        }
      } else {
        // For mobile platforms, read the file and upload
        final file = File(filePath);
        final bytes = await file.readAsBytes();
        
        // Upload to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child('evidence/$fileName');
        await storageRef.putData(bytes);
        downloadURL = await storageRef.getDownloadURL();
      }

      // Save evidence metadata to Firestore
      await _firebaseService.saveEvidence(
        title: 'Evidence ${DateTime.now().toLocal().toString().split(' ').first}',
        description: 'Uploaded evidence file',
        fileURLs: [downloadURL],
        userId: 'current_user', // Replace with actual user ID
        location: (lat != null && lon != null) ? {
          'latitude': lat,
          'longitude': lon,
        } : null,
      );

      // Add to local list for immediate display
      final ev = Evidence(
        id: const Uuid().v4(),
        filePath: downloadURL, // Use the Firebase URL instead of local path
        latitude: lat,
        longitude: lon,
      );
      _items.insert(0, ev);
      
      debugPrint('✅ Evidence uploaded to Firebase successfully!');
      
    } catch (e) {
      _uploadError = e.toString();
      debugPrint('❌ Error uploading evidence to Firebase: $e');
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
      
      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('evidence/$uniqueFileName');
      await storageRef.putData(fileBytes);
      final downloadURL = await storageRef.getDownloadURL();

      // Save evidence metadata to Firestore
      await _firebaseService.saveEvidence(
        title: 'PDF Evidence: ${fileName.split('.').first}',
        description: 'Uploaded PDF document: $fileName',
        fileURLs: [downloadURL],
        userId: 'current_user', // Replace with actual user ID
        location: null, // PDFs don't have location data
      );

      // Add to local list for immediate display
      final ev = Evidence(
        id: const Uuid().v4(),
        filePath: downloadURL, // Use the Firebase URL
        latitude: null,
        longitude: null,
      );
      _items.insert(0, ev);
      
      debugPrint('✅ PDF evidence uploaded to Firebase successfully!');
      
    } catch (e) {
      _uploadError = e.toString();
      debugPrint('❌ Error uploading PDF evidence to Firebase: $e');
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
              'filename': kIsWeb ? e.filePath.split('/').last : path.basename(e.filePath),
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
    buffer.writeln('File: ${kIsWeb ? e.filePath.split('/').last : path.basename(e.filePath)}');
    buffer.writeln(
      'Likely contents: Vegetation cover, shoreline, photo metadata consistent.',
    );
    buffer.writeln('Confidence: 78%');
    buffer.writeln(
      'Suggested actions: verify geo-tagging, provide additional photos from different angles.',
    );
    return buffer.toString();
  }
}
