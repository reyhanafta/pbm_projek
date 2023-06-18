import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'login_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProfilPage extends StatefulWidget {
  final String? userId;

  const ProfilPage({required this.userId});

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  late Reference _storageRef;
  File? _imageFile;
  String? _imageUrl;
  TextEditingController _namaController = TextEditingController();
  TextEditingController _alamatController = TextEditingController();
  TextEditingController _umurController = TextEditingController();
  LatLng? _currentPosition;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    final userId = widget.userId;
    _storageRef =
        FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
    fetchUserData();
    fetchImageUrl();
  }

  Future<void> fetchUserData() async {
    final userId = widget.userId;
    final userData = await _firestore.collection('users').doc(userId).get();

    setState(() {
      _namaController.text = userData['nama'] ?? '';
      _alamatController.text = userData['alamat'] ?? '';
      _umurController.text = userData['umur'] ?? '';
    });
  }

  Future<void> fetchImageUrl() async {
    try {
      final userId = widget.userId;
      final userData = await _firestore.collection('users').doc(userId).get();
      setState(() {
        _imageUrl = userData['profileImageUrl'];
      });
    } catch (e) {
      print('Error retrieving image URL: $e');
    }
  }

  Future<void> _selectImage(ImageSource source) async {
    final pickedImage = await _imagePicker.getImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      try {
        final uploadTask = _storageRef.putFile(_imageFile!);
        final TaskSnapshot taskSnapshot = await uploadTask;
        final downloadUrl = await taskSnapshot.ref.getDownloadURL();
        setState(() {
          _imageUrl = downloadUrl;
        });

        final userId = widget.userId;
        await _firestore
            .collection('users')
            .doc(userId)
            .update({'profileImageUrl': downloadUrl});
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> _saveChanges() async {
    final userId = widget.userId;
    await _firestore.collection('users').doc(userId).update({
      'nama': _namaController.text,
      'alamat': _alamatController.text,
      'umur': _umurController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perubahan berhasil disimpan')),
    );
  }

  Future<void> _getCurrentLocation() async {
    final status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);

        Placemark placemark = placemarks.first;
        String formattedAddress =
            '${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';

        setState(() {
          _alamatController.text = formattedAddress;
          _currentPosition = LatLng(position.latitude, position.longitude);
        });

        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _currentPosition!,
                zoom: 15,
              ),
            ),
          );
        }
      } catch (e) {
        print('Error getting current location: $e');
      }
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izin akses lokasi ditolak')),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Izin akses lokasi ditolak secara permanen. Silakan aktifkan izin melalui pengaturan perangkat.')),
      );
    }
  }

  void _logout() {
    _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout),
          ),
          IconButton(
            onPressed: _getCurrentLocation,
            icon: Icon(Icons.location_on),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage:
                    _imageUrl != null ? NetworkImage(_imageUrl!) : null,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _selectImage(ImageSource.camera),
                icon: Icon(Icons.camera_alt),
                label: Text('Ambil Foto'),
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _selectImage(ImageSource.gallery),
                icon: Icon(Icons.photo_library),
                label: Text('Pilih Dari Galeri'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama'),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _umurController,
                decoration: InputDecoration(labelText: 'Umur'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(labelText: 'Alamat'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Simpan Perubahan'),
              ),
              SizedBox(height: 16),
              if (_currentPosition != null)
                Container(
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('current_location'),
                        position: _currentPosition!,
                      ),
                    },
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
