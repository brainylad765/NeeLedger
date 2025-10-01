import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
    _requestPermissions(); // directly request permissions on start
  }

  Future<void> _requestPermissions() async {
    await Permission.storage.request();
    await Permission.location.request();
    await Geolocator.requestPermission();
  }

  Future<void> _pickAndUploadFile() async {
    try {
      setState(() {
        _isUploading = true;
          _uploadStatus = 'Selecting file...';
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls', 'json', 'pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final provider = Provider.of<UploadProvider>(context, listen: false);
        final evidenceProvider =
            Provider.of<EvidenceProvider>(context, listen: false);
        
        for (final file in result.files) {
          if (file.path == null) continue;

          File localFile = File(file.path!);
          String fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${file.name}';

          // 🔥 Firebase Storage upload
          final storageRef =
              FirebaseStorage.instance.ref().child('uploads/$fileName');

          UploadTask uploadTask = storageRef.putFile(localFile);

          uploadTask.snapshotEvents.listen((event) {
            setState(() {
              _uploadProgress =
                  event.bytesTransferred / event.totalBytes.toDouble();
              _uploadStatus =
                  'Uploading ${file.name}... ${(_uploadProgress * 100).toStringAsFixed(0)}%';
            });
          });

          final snapshot = await uploadTask;
          final downloadUrl = await snapshot.ref.getDownloadURL();

          // save locally in providers
          await provider.addPdf(file);
          if (file.bytes != null) {
            await evidenceProvider.addPdfEvidence(
              fileName: file.name,
              fileBytes: file.bytes!,
            );
          }

          setState(() {
            _uploadStatus = 'Uploaded ${file.name} ✅';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${file.name} uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      } else {
        setState(() {
          _isUploading = false;
          _uploadStatus = '';
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Upload failed: $e';
        _isUploading = false;
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Header
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
                        text:
                            _isUploading ? 'Uploading...' : 'Select & Upload File',
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
                              color: Colors.blue,
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

              // Upload History
              Consumer<UploadProvider>(
                builder: (context, provider, child) {
                  if (provider.pdfs.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Uploads',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        itemCount: provider.pdfs.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final pdf = provider.pdfs[index];
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
                                  child: Text(
                                    pdf.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
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
