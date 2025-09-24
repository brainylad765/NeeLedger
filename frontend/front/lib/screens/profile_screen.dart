import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as path;

import '../providers/user_provider.dart';
import '../providers/evidence_provider.dart';
import '../providers/document_provider.dart';
import '../widgets/new_project_form.dart';
import '../widgets/status_badge.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  late EvidenceProvider _evidenceProvider;
  late DocumentProvider _documentProvider;
  double _mapLat = 51.505;
  double _mapLon = -0.09;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _evidenceProvider = Provider.of<EvidenceProvider>(context);
    _documentProvider = Provider.of<DocumentProvider>(context);
  }

  Future<void> _capturePhoto() async {
    // show rationale if needed
    if (await Permission.camera.isDenied) {
      final again = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Camera permission'),
          content: const Text(
            'This app needs camera access to capture evidence.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Allow'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (again != true) return;
    }
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
      }
      return;
    }

    final locStatus = await Permission.location.request();
    Position? pos;
    if (locStatus.isGranted) {
      try {
        pos = await Geolocator.getCurrentPosition();
        setState(() {
          _mapLat = pos!.latitude;
          _mapLon = pos.longitude;
        });
      } catch (e) {
        // ignore
      }
    }

    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (!mounted) return;
    if (photo != null) {
      final bytes = kIsWeb ? await photo.readAsBytes() : null;
      await _evidenceProvider.addEvidence(
        photo.path,
        lat: pos?.latitude,
        lon: pos?.longitude,
        webFileBytes: bytes,
      );
      
      if (_evidenceProvider.uploadError != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload error: ${_evidenceProvider.uploadError}')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evidence uploaded to Firebase successfully!')),
          );
        }
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;
        final bytes = file.bytes!;
        final fileName = file.name;
        
        await _evidenceProvider.addPdfEvidence(
          fileName: fileName,
          fileBytes: bytes,
        );
        
        if (_evidenceProvider.uploadError != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload error: ${_evidenceProvider.uploadError}')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PDF uploaded to Firebase successfully!')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _uploadDocument() async {
    await _documentProvider.uploadDocument();
    if (_documentProvider.uploadError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: ${_documentProvider.uploadError}')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully')),
        );
      }
    }
  }

  Widget _buildMap() {
    // Use OpenStreetMap static tiles - no API key required
    final osmMapUrl =
        'https://tile.openstreetmap.org/13/${_getLongTileNumber(_mapLon, 13)}/${_getLatTileNumber(_mapLat, 13)}.png';
    
    // Fallback: Mapbox static map (you can get free API key)
    final mapboxUrl = 
        'https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/pin-s-l+FF0000($_mapLon,$_mapLat)/$_mapLon,$_mapLat,13/400x220?access_token=YOUR_MAPBOX_TOKEN';
    
    return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Current Location',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${_mapLat.toStringAsFixed(4)}, ${_mapLon.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade100, Colors.green.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Interactive-looking but static map representation
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.2, -0.3),
                            radius: 1.0,
                            colors: [
                              Colors.blue.shade200,
                              Colors.green.shade300,
                              Colors.brown.shade200,
                            ],
                          ),
                        ),
                      ),
                      // Grid pattern to simulate map tiles
                      CustomPaint(
                        size: const Size(double.infinity, double.infinity),
                        painter: MapGridPainter(),
                      ),
                      // Location marker
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 32,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'You are here',
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Map controls overlay (non-functional but visual)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Column(
                          children: [
                            _buildMapButton(Icons.add, () {}),
                            const SizedBox(height: 4),
                            _buildMapButton(Icons.remove, () {}),
                          ],
                        ),
                      ),
                      // Compass
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.navigation,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  // Helper functions for tile calculations (if using real tile maps)
  int _getLongTileNumber(double lon, int zoom) {
    return ((lon + 180) / 360 * (1 << zoom)).floor();
  }

  int _getLatTileNumber(double lat, int zoom) {
    return ((1 - log(tan(lat * pi / 180) + 1 / cos(lat * pi / 180)) / pi) / 2 * (1 << zoom)).floor();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final evProvider = Provider.of<EvidenceProvider>(context);
    final docProvider = Provider.of<DocumentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const FractionallySizedBox(
                  heightFactor: 0.9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Scaffold(body: SafeArea(child: NewProjectForm())),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'New Project',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: kAccent,
                  child: Text(
                    userProvider.isLoggedIn
                        ? userProvider.currentUser!.name.substring(0, 2).toUpperCase()
                        : 'GU',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProvider.isLoggedIn
                            ? userProvider.currentUser!.name
                            : 'Guest User',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userProvider.isLoggedIn
                            ? userProvider.currentUser!.email
                            : 'guest@example.com',
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userProvider.isLoggedIn && userProvider.currentUser!.memberSince != null
                            ? 'Member since: ${userProvider.currentUser!.memberSince!.toLocal().toString().split(' ').first}'
                            : 'Member since: N/A',
                        style: const TextStyle(fontSize: 14, color: Colors.white54),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userProvider.isLoggedIn
                            ? 'Total Evidence Uploaded: ${evProvider.items.length}'
                            : 'No evidence uploaded',
                        style: const TextStyle(fontSize: 14, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: _evidenceProvider.isUploading ? null : _capturePhoto,
                  child: _evidenceProvider.isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Capture Photo',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMap(),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Evidence (PDFs)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload PDF documents as evidence',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAccent,
                          ),
                          onPressed: _evidenceProvider.isUploading ? null : _capturePhoto,
                          icon: _evidenceProvider.isUploading 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.camera_alt),
                          label: Text(_evidenceProvider.isUploading ? 'Uploading...' : 'Capture Photo'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _evidenceProvider.isUploading ? null : _pickFile,
                          icon: _evidenceProvider.isUploading 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.upload_file),
                          label: Text(_evidenceProvider.isUploading ? 'Uploading...' : 'Upload PDF'),
                        ),
                        const Spacer(),
                        Flexible(
                          child: StatusBadge(
                            label: 'PDFs: Documents and evidence files',
                            color: kMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Documents',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _documentProvider.isUploading ? null : _uploadDocument,
                      icon: const Icon(Icons.upload_file),
                      label: _documentProvider.isUploading
                          ? const Text('Uploading...')
                          : const Text('Upload PDF Document'),
                    ),
                    if (_documentProvider.uploadError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Error: ${_documentProvider.uploadError}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Uploaded Documents:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...docProvider.uploadedDocuments.map(
                      (url) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          url,
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Recent Evidence',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // horizontal thumbnails
            if (evProvider.items.isNotEmpty)
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: evProvider.items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final ev = evProvider.items[i];
                    return GestureDetector(
                      onTap: () {
                        // expand by navigating to detail or scroll to tile; for now show dialog
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => Padding(
                            padding: const EdgeInsets.all(12),
                            child: _evidenceTile(ev),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: kCard,
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ev.timestamp.toLocal().toString().split(' ').first,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            // full expandable list
            Column(
              children: evProvider.items.map((e) => _evidenceTile(e)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _evidenceTile(e) {
    return Card(
      child: ExpansionTile(
        title: Text(
          e.filePath.contains('firebase') 
              ? 'PDF Document (${e.filePath.split('/').last.split('_').skip(1).join('_')})'
              : (kIsWeb ? e.filePath.split('/').last : path.basename(e.filePath)),
        ),
        subtitle: Text(e.timestamp.toLocal().toString()),
        leading: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(
            Icons.picture_as_pdf,
            color: Colors.red,
            size: 40,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: FutureBuilder<String>(
              future: _evidenceProvider.generateXAIReport(e),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return SelectableText(snapshot.data ?? 'No report');
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for map grid lines
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 0.5;

    const gridSize = 30.0;
    
    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Add some random "roads" or "paths" for realism
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.0;

    // Horizontal road
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      roadPaint,
    );

    // Vertical road
    canvas.drawLine(
      Offset(size.width * 0.6, 0),
      Offset(size.width * 0.6, size.height),
      roadPaint,
    );

    // Diagonal path
    canvas.drawLine(
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.4, size.height * 0.4),
      Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
