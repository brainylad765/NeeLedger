import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';

class DocumentProvider with ChangeNotifier {
  final List<String> _uploadedDocuments = [];
  final List<Map<String, dynamic>> _allDocuments = [];
  final FirebaseService _firebaseService = FirebaseService();

  List<String> get uploadedDocuments => List.unmodifiable(_uploadedDocuments);
  List<Map<String, dynamic>> get allDocuments => List.unmodifiable(_allDocuments);

  DocumentProvider() {
    // Listen to real-time document updates from Firebase
    _firebaseService.listenToDocuments((documents) {
      _allDocuments.clear();
      _allDocuments.addAll(documents);
      notifyListeners();
    });
  }

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  String? _uploadError;
  String? get uploadError => _uploadError;

  Future<void> uploadDocument() async {
    _isUploading = true;
    _uploadError = null;
    notifyListeners();

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Prefer PDF as per user request
      );

      if (result != null) {
        // On web, path is not available, use bytes instead
        final fileBytes = result.files.single.bytes;
        final fileName = result.files.single.name;

        if (fileBytes != null) {
          // Upload to Firebase Storage using bytes
          final storageRef = FirebaseStorage.instance.ref().child('documents/${const Uuid().v4()}_$fileName');
          await storageRef.putData(fileBytes);

          // Get download URL
          String downloadURL = await storageRef.getDownloadURL();

          // Save to Firebase for real-time sync across devices
          await _firebaseService.saveDocument(
            fileName: fileName,
            downloadURL: downloadURL,
            uploadedBy: 'current_user', // Replace with actual user ID
            metadata: {
              'fileSize': fileBytes.length,
              'uploadedFromDevice': 'this_device',
            },
          );

          // Also send to your existing backend for compatibility
          try {
            await ApiService().uploadDocumentMetadata(downloadURL, fileName);
          } catch (e) {
            debugPrint('Warning: Failed to sync with backend API: $e');
          }

          // Add to local list after successful upload
          _uploadedDocuments.add(downloadURL);

          notifyListeners();
        } else {
          _uploadError = 'File bytes are null';
          notifyListeners();
        }
      }
    } catch (e) {
      _uploadError = e.toString();
      notifyListeners();
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _uploadError = null;
    notifyListeners();
  }

  // Load existing documents from Firebase
  Future<void> loadDocuments() async {
    try {
      final documents = await _firebaseService.getDocumentsList();
      _allDocuments.clear();
      _allDocuments.addAll(documents);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading documents: $e');
    }
  }
}
