import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../models/project_document.dart';

class DocumentUploadService {
  static final DocumentUploadService _instance = DocumentUploadService._internal();
  factory DocumentUploadService() => _instance;
  DocumentUploadService._internal();

  final _supabase = Supabase.instance.client;
  static const String bucketName = 'project-documents';

  /// Upload a document to Supabase storage and create project record
  Future<ProjectDocument> uploadDocument({
    required PlatformFile file,
    required String title,
    String? description,
    String? location,
    String projectType = 'general',
    int carbonCredits = 0,
    double investmentAmount = 0.00,
    DateTime? startDate,
    DateTime? endDate,
    Function(double)? onProgress,
  }) async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Validate file
      _validateFile(file);

      // Generate unique file path
      final fileExtension = path.extension(file.name);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final filePath = '${user.id}/$fileName';

      // Get file bytes
      Uint8List fileBytes;
      if (kIsWeb) {
        fileBytes = file.bytes!;
      } else {
        fileBytes = await File(file.path!).readAsBytes();
      }

      // Upload progress callback
      onProgress?.call(0.1);

      // Upload to Supabase storage
      await _supabase.storage.from(bucketName).uploadBinary(
        filePath,
        fileBytes,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );

      onProgress?.call(0.7);

      // Get public URL
      final fileUrl = _supabase.storage.from(bucketName).getPublicUrl(filePath);

      // Create project record in database
      final projectData = {
        'user_id': user.id,
        'title': title,
        'description': description,
        'file_url': fileUrl,
        'file_name': fileName,
        'file_size': file.size,
        'file_type': fileExtension,
        'project_type': projectType,
        'status': 'active',
        'location': location,
        'carbon_credits': carbonCredits,
        'investment_amount': investmentAmount,
        'progress': 0.0,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      };

      final response = await _supabase
          .from('projects')
          .insert(projectData)
          .select()
          .single();

      onProgress?.call(0.9);

      // Create document upload record
      await _supabase.from('document_uploads').insert({
        'user_id': user.id,
        'project_id': response['id'],
        'file_name': fileName,
        'original_name': file.name,
        'file_path': filePath,
        'file_url': fileUrl,
        'file_size': file.size,
        'mime_type': _getMimeType(fileExtension),
        'upload_status': 'completed',
      });

      onProgress?.call(1.0);

      // Return ProjectDocument model
      return ProjectDocument.fromMap(response);
    } on StorageException catch (e) {
      throw Exception('Storage error: ${e.message}');
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  /// Pick and upload document with UI
  Future<ProjectDocument?> pickAndUploadDocument({
    required String title,
    String? description,
    String? location,
    String projectType = 'general',
    int carbonCredits = 0,
    double investmentAmount = 0.00,
    DateTime? startDate,
    DateTime? endDate,
    Function(double)? onProgress,
  }) async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;

      // Upload the selected file
      return await uploadDocument(
        file: file,
        title: title,
        description: description,
        location: location,
        projectType: projectType,
        carbonCredits: carbonCredits,
        investmentAmount: investmentAmount,
        startDate: startDate,
        endDate: endDate,
        onProgress: onProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch all user documents
  Future<List<ProjectDocument>> fetchUserDocuments() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('projects')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response.map<ProjectDocument>((data) => ProjectDocument.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch documents: $e');
    }
  }

  /// Fetch documents by project type
  Future<List<ProjectDocument>> fetchDocumentsByType(String projectType) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('projects')
          .select()
          .eq('user_id', user.id)
          .eq('project_type', projectType)
          .order('created_at', ascending: false);

      return response.map<ProjectDocument>((data) => ProjectDocument.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch documents by type: $e');
    }
  }

  /// Update project document
  Future<ProjectDocument> updateDocument({
    required String projectId,
    String? title,
    String? description,
    String? location,
    String? status,
    int? carbonCredits,
    double? investmentAmount,
    double? progress,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (location != null) updateData['location'] = location;
      if (status != null) updateData['status'] = status;
      if (carbonCredits != null) updateData['carbon_credits'] = carbonCredits;
      if (investmentAmount != null) updateData['investment_amount'] = investmentAmount;
      if (progress != null) updateData['progress'] = progress;
      if (startDate != null) updateData['start_date'] = startDate.toIso8601String();
      if (endDate != null) updateData['end_date'] = endDate.toIso8601String();

      final response = await _supabase
          .from('projects')
          .update(updateData)
          .eq('id', projectId)
          .eq('user_id', user.id)
          .select()
          .single();

      return ProjectDocument.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  /// Delete project document
  Future<void> deleteDocument(String projectId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get document info first
      final document = await _supabase
          .from('projects')
          .select('file_name')
          .eq('id', projectId)
          .eq('user_id', user.id)
          .single();

      // Delete from storage
      final filePath = '${user.id}/${document['file_name']}';
      await _supabase.storage.from(bucketName).remove([filePath]);

      // Delete from database (this will cascade delete document_uploads due to foreign key)
      await _supabase
          .from('projects')
          .delete()
          .eq('id', projectId)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  /// Get download URL for a document
  Future<String> getDownloadUrl(String projectId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final document = await _supabase
          .from('projects')
          .select('file_name')
          .eq('id', projectId)
          .eq('user_id', user.id)
          .single();

      final filePath = '${user.id}/${document['file_name']}';
      return _supabase.storage.from(bucketName).createSignedUrl(filePath, 3600); // 1 hour expiry
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  /// Search documents
  Future<List<ProjectDocument>> searchDocuments(String query) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('projects')
          .select()
          .eq('user_id', user.id)
          .or('title.ilike.%$query%,description.ilike.%$query%,location.ilike.%$query%')
          .order('created_at', ascending: false);

      return response.map<ProjectDocument>((data) => ProjectDocument.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to search documents: $e');
    }
  }

  /// Get project statistics
  Future<Map<String, dynamic>> getProjectStats() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('projects')
          .select()
          .eq('user_id', user.id);

      final projects = response.map<ProjectDocument>((data) => ProjectDocument.fromMap(data)).toList();

      return {
        'total_projects': projects.length,
        'active_projects': projects.where((p) => p.status == 'active').length,
        'completed_projects': projects.where((p) => p.status == 'completed').length,
        'total_carbon_credits': projects.fold<int>(0, (sum, p) => sum + p.carbonCredits),
        'total_investment': projects.fold<double>(0.0, (sum, p) => sum + p.investmentAmount),
        'average_progress': projects.isNotEmpty 
            ? projects.fold<double>(0.0, (sum, p) => sum + p.progress) / projects.length
            : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get project stats: $e');
    }
  }

  /// Validate file before upload
  void _validateFile(PlatformFile file) {
    const maxFileSize = 50 * 1024 * 1024; // 50MB
    const allowedExtensions = ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'];

    if (file.size > maxFileSize) {
      throw Exception('File size must be less than 50MB');
    }

    final extension = path.extension(file.name).toLowerCase().substring(1);
    if (!allowedExtensions.contains(extension)) {
      throw Exception('File type not supported. Allowed: ${allowedExtensions.join(', ')}');
    }
  }

  /// Get MIME type from file extension
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.txt':
        return 'text/plain';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }
}