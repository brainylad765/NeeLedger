import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/user_provider.dart';

import 'yourprojects_screen.dart';
import 'uploads_screen.dart';
import 'recent_trans.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Sabrina Aryan',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'sabrina@gmail.com',
  );

  // Map (centered on Kutch, Gujarat)
  LatLng _center = LatLng(23.7333, 69.6667);
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  String _placeName = 'Kutch, Gujarat';
  bool _mapLoading = false;
  bool _locationLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _reverseGeocode(_center.latitude, _center.longitude);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onMapMove(MapCamera camera) {
    final center = camera.center;
    _center = center;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _reverseGeocode(center.latitude, center.longitude);
    });
  }

  Future<void> _reverseGeocode(double lat, double lon) async {
    setState(() => _mapLoading = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon',
      );
      final resp = await http.get(uri, headers: {'User-Agent': 'front-app'});
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() => _placeName = data['display_name'] ?? 'Unknown place');
      } else {
        print('Geocoding failed with status: ${resp.statusCode}');
        setState(
          () => _placeName =
              'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lon.toStringAsFixed(4)}',
        );
      }
    } catch (e) {
      print('Geocoding error: $e');
      setState(
        () => _placeName =
            'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lon.toStringAsFixed(4)}',
      );
    } finally {
      setState(() => _mapLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _locationLoading = true);
    try {
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = newLocation;
        _center = newLocation;
      });

      _mapController.move(newLocation, _mapController.camera.zoom);
      await _reverseGeocode(newLocation.latitude, newLocation.longitude);
    } catch (e) {
      print('Error getting location: $e');
      // Fallback to default location
    } finally {
      setState(() => _locationLoading = false);
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location access is needed to show your current position on the map.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _openEditNameDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // settings
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF0F1416),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Header: avatar + name/email + edit
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final user = userProvider.currentUser;
                String displayName = 'User';
                String displayEmail = '';

                if (user != null) {
                  displayEmail = user.email;
                  // Extract username from email (part before @)
                  displayName = user.email.split('@').first;
                  _nameController.text = displayName;
                  _emailController.text = displayEmail;
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF0D47A1),
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                    onPressed: _openEditNameDialog,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayEmail,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Profile card with Map + Menu
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 260,
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            _placeName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            'Lat: ${_center.latitude.toStringAsFixed(4)}, Lng: ${_center.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: _mapLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF0D47A1),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: _center,
                                  initialZoom: 9.0,
                                  onMapEvent: (event) =>
                                      _onMapMove(event.camera),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    subdomains: const ['a', 'b', 'c'],
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: _currentLocation ?? _center,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: Colors.red,
                                          size: 36,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (_locationLoading)
                                const Positioned(
                                  top: 10,
                                  left: 10,
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF0D47A1),
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: FloatingActionButton(
                                  mini: true,
                                  onPressed: _getCurrentLocation,
                                  backgroundColor: const Color(0xFF0D47A1),
                                  child: const Icon(
                                    Icons.my_location,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu items
                  ListTile(
                    leading: const Icon(
                      Icons.folder_open,
                      color: Color(0xFF0D47A1),
                    ),
                    title: const Text(
                      'Your Projects',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => YourProjectsScreen()),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.cloud_upload,
                      color: Color(0xFF0D47A1),
                    ),
                    title: const Text(
                      'Uploads',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UploadsScreen()),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: Color(0xFF0D47A1),
                    ),
                    title: const Text(
                      'Location (Map above)',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      // Optionally open a full-screen map in future
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.receipt_long,
                      color: Color(0xFF0D47A1),
                    ),
                    title: const Text(
                      'Recent Transactions',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RecentTransScreen(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Color(0xFF0D47A1)),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      // log out
                    },
                  ),

                  // App version
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'App Version 3.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
