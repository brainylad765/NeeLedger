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
  bool _hasPermissions = false;
  String _uploadStatus = '';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _getCurrentLocation();
  }

  Future<void> _checkPermissions() async {
    final storageStatus = await Permission.storage.status;
    LocationPermission locationPermission = await Geolocator.checkPermission();
    final locationStatus =
        locationPermission == LocationPermission.always ||
        locationPermission == LocationPermission.whileInUse;

    setState(() {
      _hasPermissions = storageStatus.isGranted && locationStatus;
    });
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationDialog();
      return;
    }

    // Permission granted, no need to get position since this is data upload screen
  }

  Future<void> _showLocationDialog() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location Access Required'),
        content: const Text(
          'Location access is required for data uploads. Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermissions() async {
    final storageStatus = await Permission.storage.request();
    final locationStatus = await Permission.location.request();

    setState(() {
      _hasPermissions = storageStatus.isGranted && locationStatus.isGranted;
    });

    if (!_hasPermissions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Storage and Location permissions are required for data upload',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickAndUploadFile() async {
    if (!_hasPermissions) {
      await _requestPermissions();
      if (!_hasPermissions) return;
    }

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
        setState(() {
          _uploadStatus = 'Uploading files...';
        });

        final provider = Provider.of<UploadProvider>(context, listen: false);
        for (final file in result.files) {
          await provider.addPdf(file);
        }
        
        // Also sync to Evidence Provider for cross-platform compatibility
        final evidenceProvider = Provider.of<EvidenceProvider>(context, listen: false);
        for (final file in result.files) {
          if (file.bytes != null) {
            await evidenceProvider.addPdfEvidence(
              fileName: file.name,
              fileBytes: file.bytes!,
            );
          }
        }

        setState(() {
          _uploadStatus = 'Files uploaded successfully!';
          _isUploading = false;
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

  void _pickAndUploadFileSync() {
    _pickAndUploadFile();
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

              // Permissions Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _hasPermissions
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF9800),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _hasPermissions ? Icons.check_circle : Icons.warning,
                          color: _hasPermissions
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF9800),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _hasPermissions
                              ? 'Permissions Granted'
                              : 'Permissions Required',
                          style: TextStyle(
                            color: _hasPermissions
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF9800),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Storage and Location permissions are required to upload data files to our real-time cloud service.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    if (!_hasPermissions)
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Grant Permissions',
                          onPressed: _requestPermissions,
                        ),
                      ),
                  ],
                ),
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
              Consumer<UploadProvider>(
                builder: (context, provider, child) {
                  final hasUploads = provider.pdfs.isNotEmpty || provider.images.isNotEmpty;
                  return Text(
                    hasUploads 
                        ? 'Upload your monitoring documents here'
                        : 'Upload your PDD projects to initiate',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
                    const SizedBox(height: 12),
              Consumer<UploadProvider>(
                builder: (context, provider, child) {
                  final hasUploads = provider.pdfs.isNotEmpty || provider.images.isNotEmpty;
                  return Text(
                    hasUploads
                        ? 'Upload monitoring documents, reports, and additional project files'
                        : 'Supported formats: CSV, Excel (.xlsx, .xls), JSON, PDF - Upload your initial PDD documents',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  );
                },
              ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: _isUploading
                            ? 'Uploading...'
                            : 'Select & Upload File',
                        onPressed: _hasPermissions
                            ? _pickAndUploadFileSync
                            : () {},
                      ),
                    ),
                    if (_uploadStatus.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _uploadStatus,
                          style: TextStyle(
                            color: _uploadStatus.contains('failed')
                                ? Colors.red
                                : _uploadStatus.contains('successfully')
                                ? Colors.green
                                : Colors.blue,
                            fontSize: 14,
                          ),
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
                                const SizedBox(width: 8),
                                Text(
                                  '${(pdf.size / 1024).toStringAsFixed(1)} KB',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF4CAF50,
                                    ).withValues(alpha: 51),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Uploaded',
                                    style: TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontSize: 12,
                                    ),
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

              const SizedBox(height: 32),

              // Real-time Status
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF0D47A1).withValues(alpha: 77),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Real-time Sync Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSyncStatus('Firebase', 'Connected', Colors.green),
                        _buildSyncStatus(
                          'Cloud Storage',
                          'Active',
                          Colors.blue,
                        ),
                        _buildSyncStatus(
                          'Real-time DB',
                          'Syncing',
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatus(String service, String status, Color color) {
    return Column(
      children: [
        Text(
          service,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 51),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
