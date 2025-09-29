import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/upload_provider.dart';

class DebugUploadsScreen extends StatefulWidget {
  static const String routeName = '/debug-uploads';
  
  const DebugUploadsScreen({Key? key}) : super(key: key);

  @override
  State<DebugUploadsScreen> createState() => _DebugUploadsScreenState();
}

class _DebugUploadsScreenState extends State<DebugUploadsScreen> {
  @override
  void initState() {
    super.initState();
    // Load Supabase documents when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UploadProvider>(context, listen: false).loadSupabaseDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UploadProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Debug: Upload Storage'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => provider.loadSupabaseDocuments(),
              ),
              Switch(
                value: provider.isSupabaseEnabled,
                onChanged: provider.toggleSupabaseIntegration,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard(
                        'Local Storage',
                        '${provider.pdfs.length + provider.images.length} files',
                        'Cleared on hot reload',
                        Colors.orange,
                        Icons.storage,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatusCard(
                        'Supabase Storage',
                        '${provider.supabaseDocuments.length} files',
                        'Persistent storage',
                        Colors.green,
                        Icons.cloud,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Supabase Status
                _buildSupabaseStatus(provider),
                
                const SizedBox(height: 24),
                
                // Local Files Section
                _buildSection(
                  'Local Files (Temporary)',
                  'These files are cleared on hot reload',
                  Icons.storage,
                  Colors.orange,
                  _buildLocalFilesList(provider),
                ),
                
                const SizedBox(height: 24),
                
                // Supabase Files Section
                _buildSection(
                  'Supabase Files (Persistent)',
                  'These files persist until manually deleted',
                  Icons.cloud,
                  Colors.green,
                  _buildSupabaseFilesList(provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(String title, String count, String subtitle, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupabaseStatus(UploadProvider provider) {
    return Card(
      color: provider.isSupabaseEnabled ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  provider.isSupabaseEnabled ? Icons.cloud_done : Icons.cloud_off,
                  color: provider.isSupabaseEnabled ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Supabase Integration',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: provider.isSupabaseEnabled,
                  onChanged: provider.toggleSupabaseIntegration,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              provider.isSupabaseEnabled 
                ? 'Files will be uploaded to both local and Supabase storage'
                : 'Files will only be uploaded to local storage',
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            if (provider.isSupabaseUploading) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Uploading to Supabase...'),
                ],
              ),
            ],
            if (provider.supabaseError != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.supabaseError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: provider.clearSupabaseError,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, IconData icon, Color color, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildLocalFilesList(UploadProvider provider) {
    final allLocalFiles = [
      ...provider.pdfs.map((pdf) => {
        'type': 'PDF',
        'name': pdf.name,
        'size': '${(pdf.size / 1024).toStringAsFixed(1)} KB',
        'timestamp': pdf.timestamp,
        'id': pdf.id,
      }),
      ...provider.images.map((img) => {
        'type': 'Image',
        'name': img.path.split('/').last,
        'size': 'Unknown',
        'timestamp': img.timestamp,
        'id': img.id,
        'location': img.latitude != null && img.longitude != null 
          ? '${img.latitude!.toStringAsFixed(4)}, ${img.longitude!.toStringAsFixed(4)}'
          : null,
      }),
    ];

    if (allLocalFiles.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No local files uploaded yet'),
        ),
      );
    }

    return Column(
      children: allLocalFiles.map((file) => Card(
        child: ListTile(
          leading: Icon(
            file['type'] == 'PDF' ? Icons.picture_as_pdf : Icons.image,
            color: file['type'] == 'PDF' ? Colors.red : Colors.blue,
          ),
          title: Text(file['name'] as String),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${file['type']} • ${file['size']}'),
              Text('Uploaded: ${(file['timestamp'] as DateTime).toString().substring(0, 19)}'),
              if (file['location'] != null)
                Text('Location: ${file['location']}'),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              if (file['type'] == 'Image') {
                provider.removeImage(file['id'] as String);
              }
              // Note: No remove method for PDFs in current implementation
            },
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildSupabaseFilesList(UploadProvider provider) {
    if (provider.supabaseDocuments.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('No Supabase files found'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: provider.loadSupabaseDocuments,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: provider.supabaseDocuments.map((doc) => Card(
        child: ListTile(
          leading: Icon(
            doc['file_type'] == 'pdf' ? Icons.picture_as_pdf : Icons.image,
            color: doc['file_type'] == 'pdf' ? Colors.red : Colors.blue,
          ),
          title: Text(doc['file_name'] ?? 'Unknown'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${doc['file_type']?.toUpperCase()} • ${_formatFileSize(doc['file_size'])}'),
              Text('Uploaded: ${doc['upload_timestamp']?.substring(0, 19) ?? 'Unknown'}'),
              if (doc['latitude'] != null && doc['longitude'] != null)
                Text('Location: ${doc['latitude']}, ${doc['longitude']}'),
              if (doc['local_id'] != null)
                Text('Local ID: ${doc['local_id']}', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.open_in_new, color: Colors.blue),
                onPressed: () {
                  // TODO: Open file URL
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('File URL: ${doc['file_url']}')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, provider, doc),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  String _formatFileSize(dynamic size) {
    if (size == null) return 'Unknown';
    final bytes = size is int ? size : int.tryParse(size.toString()) ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _confirmDelete(BuildContext context, UploadProvider provider, Map<String, dynamic> doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to permanently delete "${doc['file_name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteSupabaseDocument(doc['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}