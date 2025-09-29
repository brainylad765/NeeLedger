import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_button.dart';
import '../providers/upload_provider.dart';
import '../providers/evidence_provider.dart';

class DataScreen extends StatefulWidget {
  static const String routeName = '/data';

  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  bool _isUploading = false;
  String _uploadStatus = '';
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.storage.request();
    await Permission.location.request();
    await Geolocator.requestPermission();
  }

  Future<void> _pickAndUploadFile() async {
    final provider = Provider.of<UploadProvider>(context, listen: false);
    try {
      setState(() {
        _isUploading = true;
        _uploadStatus = 'Selecting file...';
        _uploadProgress = 0.0;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls', 'json', 'pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        int currentFile = 0;
        for (final file in result.files) {
          currentFile++;
          if (file.path == null && file.bytes == null) continue;

          setState(() {
            _uploadStatus =
                'Uploading ${file.name} (${currentFile}/${result.files.length})...';
            _uploadProgress = (currentFile - 1) / result.files.length;
          });

          // Use UploadProvider to add PDF and handle upload & project creation
          await provider.addPdf(
            PlatformFile(
              name: file.name,
              size: file.size,
              bytes: file.bytes,
              path: file.path,
            ),
          );

          setState(() {
            _uploadProgress = currentFile / result.files.length;
          });
        }

        setState(() {
          _uploadStatus = 'All files uploaded successfully! ✅';
          _isUploading = false;
          _uploadProgress = 1.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${result.files.length} file(s) uploaded successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _uploadStatus = '';
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Upload failed: $e';
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadProvider = Provider.of<UploadProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Header - show only if there are uploads
              if (uploadProvider.hasUploads)
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.cloud_upload,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Data Upload',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // Upload Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Files',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Supported formats: CSV, Excel, JSON, PDF',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: _isUploading
                            ? 'Uploading...'
                            : 'Select & Upload File',
                        onPressed: _isUploading ? () {} : _pickAndUploadFile,
                      ),
                    ),
                    if (_uploadStatus.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: _isUploading ? _uploadProgress : null,
                              backgroundColor: Colors.grey[800],
                              color: const Color(0xFF0D47A1),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _uploadStatus,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Evidence History
              Consumer<EvidenceProvider>(
                builder: (context, evidenceProvider, child) {
                  if (evidenceProvider.items.isEmpty)
                    return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Evidence History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        itemCount: evidenceProvider.items.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final evidence = evidenceProvider.items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.file_present,
                                  color: Color(0xFF0D47A1),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        evidence.filePath.split('/').last,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (evidence.latitude != null &&
                                          evidence.longitude != null)
                                        Text(
                                          '${evidence.latitude!.toStringAsFixed(4)}, ${evidence.longitude!.toStringAsFixed(4)}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      Text(
                                        evidence.timestamp.toString().split(
                                          'T',
                                        )[0],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Uploaded',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
