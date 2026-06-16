import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A widget to pick, display, and persist a user's profile picture.
class ProfilePictureUploader extends StatefulWidget {
  const ProfilePictureUploader({Key? key}) : super(key: key);

  @override
  State<ProfilePictureUploader> createState() => _ProfilePictureUploaderState();
}

class _ProfilePictureUploaderState extends State<ProfilePictureUploader> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  static const String _profileImagePathKey = 'profile_image_path';

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString(_profileImagePathKey);
    if (imagePath != null && imagePath.isNotEmpty) {
      setState(() {
        _imageFile = File(imagePath);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _saveProfileImage(pickedFile.path);
    }
  }

  Future<void> _saveProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImagePathKey, path);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
            child: _imageFile == null
                ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                : null,
          ),
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Change Profile Picture'),
            onPressed: _pickImage,
          ),
        ],
      ),
    );
  }
}
