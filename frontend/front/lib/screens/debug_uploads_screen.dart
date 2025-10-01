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
    // Supabase-related code removed
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UploadProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Debug: Upload Storage')),
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
                        'Persistent Storage',
                        '0 files',
                        'Feature removed',
                        Colors.grey,
                        Icons.cloud_off,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Local Files Section
                _buildSection(
                  'Local Files (Temporary)',
                  'These files are cleared on hot reload',
                  Icons.storage,
                  Colors.orange,
                  _buildLocalFilesList(provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(
    String title,
    String count,
    String subtitle,
    Color color,
    IconData icon,
  ) {
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
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget content,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildLocalFilesList(UploadProvider provider) {
    final allLocalFiles = [
      ...provider.pdfs.map(
        (pdf) => {
          'type': 'PDF',
          'name': pdf.name,
          'size': '${(pdf.size / 1024).toStringAsFixed(1)} KB',
          'timestamp': pdf.timestamp,
          'id': pdf.id,
        },
      ),
      ...provider.images.map(
        (img) => {
          'type': 'Image',
          'name': img.path.split('/').last,
          'size': 'Unknown',
          'timestamp': img.timestamp,
          'id': img.id,
          'location': img.latitude != null && img.longitude != null
              ? '${img.latitude!.toStringAsFixed(4)}, ${img.longitude!.toStringAsFixed(4)}'
              : null,
        },
      ),
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
      children: allLocalFiles
          .map(
            (file) => Card(
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
                    Text(
                      'Uploaded: ${(file['timestamp'] as DateTime).toString().substring(0, 19)}',
                    ),
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
            ),
          )
          .toList(),
    );
  }
}
