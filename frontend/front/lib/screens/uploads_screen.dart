import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../providers/upload_provider.dart';

class UploadsScreen extends StatefulWidget {
  const UploadsScreen({Key? key}) : super(key: key);
  static const routeName = '/uploads';

  @override
  State<UploadsScreen> createState() => _UploadsScreenState();
}

class _UploadsScreenState extends State<UploadsScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _imageFlowActive = false;
  // bool _cameraPermissionGranted = false;  // Removed unused field
  int _capturedImagesCount = 0;
  Timer? _countdownTimer;
  int _countdownSeconds = 3;
  bool _showingCountdown = false;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Pick multiple PDFs and add to provider
  Future<void> _pickPdfs() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (res == null) return;

    final provider = Provider.of<UploadProvider>(context, listen: false);
    for (final file in res.files) {
      await provider.addPdf(file);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF(s) uploaded successfully')),
      );
    }
  }

  /// Step 1: Request location permission → Step 2: Request camera permission → Start camera flow
  Future<void> _startImageFlow() async {
    if (_capturedImagesCount >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 images allowed. Limit reached.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Request location permission
    final locStatus = await Permission.locationWhenInUse.request();
    if (!locStatus.isGranted) {
      _handlePermissionError(
        locStatus,
        title: 'Location Access Required',
        message:
            'BlockZen needs location to geotag your images. Please enable it.',
      );
      return;
    }

    // Request camera permission
    final camStatus = await Permission.camera.request();
    if (!camStatus.isGranted) {
      _handlePermissionError(
        camStatus,
        title: 'Camera Access Required',
        message: 'Camera access is needed to capture images. Please enable it.',
      );
      return;
    }

    // Both permissions granted - start countdown and capture
    setState(() {
      _imageFlowActive = true;
    });
    
    _startCountdownAndCapture();
  }

  /// Start countdown and automatically capture image
  void _startCountdownAndCapture() {
    setState(() {
      _showingCountdown = true;
      _countdownSeconds = 3;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownSeconds--;
      });

      if (_countdownSeconds <= 0) {
        timer.cancel();
        setState(() => _showingCountdown = false);
        _captureImage();
      }
    });
  }

  /// Handle permission denials consistently
  Future<void> _handlePermissionError(
    PermissionStatus status, {
    required String title,
    required String message,
  }) async {
    if (status.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(message),
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
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  /// Capture image + GPS
  Future<void> _captureImage() async {
    final provider = Provider.of<UploadProvider>(context, listen: false);
    if (_capturedImagesCount >= 5) return;

    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (xfile == null) return;

    Position pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      pos = Position(
        timestamp: DateTime.now(),
        latitude: 0,
        longitude: 0,
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }

    await provider.addImage(File(xfile.path), pos.latitude, pos.longitude);
    
    setState(() {
      _capturedImagesCount++;
    });

    // Show capture feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _capturedImagesCount >= 5 
                ? '5/5 - Maximum images captured!'
                : '$_capturedImagesCount/5 - Image captured successfully!',
          ),
          backgroundColor: _capturedImagesCount >= 5 ? Colors.green : Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Continue capturing if under limit
    if (_capturedImagesCount < 5) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) _startCountdownAndCapture();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UploadProvider>(
      builder: (context, provider, child) => Scaffold(
        appBar: AppBar(title: const Text('Uploads')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload PDD documents to start your project',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              /// Buttons row
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickPdfs,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Upload PDF'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _capturedImagesCount >= 5 ? null : _startImageFlow,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_capturedImagesCount >= 5 ? '5/5 Images' : 'Upload Images'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              /// Show countdown overlay
              if (_showingCountdown)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Get Ready!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$_countdownSeconds',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Image ${_capturedImagesCount + 1}/5',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

              /// Show capture progress
              if (_imageFlowActive && !_showingCountdown)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Images Captured: $_capturedImagesCount/5',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_capturedImagesCount < 5)
                            ElevatedButton(
                              onPressed: _startCountdownAndCapture,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Capture Next'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: _capturedImagesCount / 5,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      if (_capturedImagesCount >= 5)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            '✅ All 5 images captured! No more photos allowed.',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              /// Show PDFs list
              if (provider.pdfs.isNotEmpty) ...[
                const Text('Selected PDFs:'),
                const SizedBox(height: 8),
                for (var f in provider.pdfs)
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: Text(f.name),
                    subtitle: Text('${(f.size / 1024).toStringAsFixed(1)} KB'),
                  ),
                const SizedBox(height: 12),
              ],

              /// Show image flow
              if (_imageFlowActive) ...[
                Row(
                  children: [
                    Text(
                      '${provider.images.length}/5',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: provider.images.isEmpty
                            ? 0
                            : provider.images
                                      .map((e) => e.progress)
                                      .fold<double>(0, (a, b) => a + b) /
                                  500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: provider.images.length >= 5
                          ? null
                          : _captureImage,
                      icon: const Icon(Icons.camera),
                      label: const Text('Capture'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// Grid view of images
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: provider.images.length,
                  itemBuilder: (_, i) {
                    final it = provider.images[i];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(it.path), fit: BoxFit.cover),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: _overlayText('${it.progress.toInt()}%'),
                        ),
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: _overlayText(
                            '${it.latitude?.toStringAsFixed(4) ?? '0.0000'}, '
                            '${it.longitude?.toStringAsFixed(4) ?? '0.0000'}',
                            fontSize: 10,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                if (provider.images.length >= 5)
                  const Text(
                    'Maximum images uploaded. Capture disabled.',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Helper for overlay texts on images
  Widget _overlayText(String text, {double fontSize = 12}) {
    return Container(
      padding: const EdgeInsets.all(4),
      color: Colors.black45,
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: fontSize),
      ),
    );
  }
}
