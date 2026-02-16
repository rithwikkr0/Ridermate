import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_provider.dart';
import '../services/user_profile_service.dart';
import '../utils/validation_utils.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final UserProfileService _profileService = UserProfileService();
  final ImagePicker _imagePicker = ImagePicker();
  
  String _selectedPrivacyMode = 'public';
  File? _selectedImage;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userProfile;
    
    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _selectedPrivacyMode = user.privacyMode;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.firebaseUser?.uid;
      
      if (userId == null) throw Exception('No user logged in');

      Map<String, dynamic> updates = {
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        'phoneNumber': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'privacyMode': _selectedPrivacyMode,
      };

      // Upload profile photo if changed
      if (_selectedImage != null) {
        final photoUrl = await _profileService.uploadProfilePhoto(userId, _selectedImage!);
        updates['profilePhoto'] = photoUrl;
      }

      // Update profile
      final success = await authProvider.updateProfile(updates);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_hasChanges) {
              _showDiscardChangesDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveChanges,
              child: Text(
                'Save',
                style: TextStyle(
                  color: Color(0xFF0066FF),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.userProfile;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                onChanged: () {
                  setState(() {
                    _hasChanges = true;
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    
                    // Profile Photo
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Color(0xFF0066FF), width: 3),
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : (user?.profilePhoto != null
                                    ? DecorationImage(
                                        image: NetworkImage(user!.profilePhoto!),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                            color: _selectedImage == null && user?.profilePhoto == null
                                ? Color(0xFF0066FF)
                                : null,
                          ),
                          child: _selectedImage == null && user?.profilePhoto == null
                              ? Center(
                                  child: Text(
                                    user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xFF0066FF),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 40),
                    
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.person, color: Color(0xFF0066FF)),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF0066FF), width: 2),
                        ),
                      ),
                      validator: ValidationUtils.validateNameField,
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Bio Field
                    TextFormField(
                      controller: _bioController,
                      style: TextStyle(color: Colors.white),
                      maxLines: 4,
                      maxLength: 500,
                      decoration: InputDecoration(
                        labelText: 'Bio (Optional)',
                        labelStyle: TextStyle(color: Colors.grey),
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.description, color: Color(0xFF0066FF)),
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF0066FF), width: 2),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Phone Number (Optional)',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.phone, color: Color(0xFF0066FF)),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF0066FF), width: 2),
                        ),
                      ),
                      validator: ValidationUtils.validatePhoneField,
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Privacy Mode Section
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Mode',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 15),
                          _buildPrivacyOption('public', 'Public', 'Everyone can see your profile'),
                          SizedBox(height: 10),
                          _buildPrivacyOption('friends-only', 'Friends Only', 'Only friends can see your profile'),
                          SizedBox(height: 10),
                          _buildPrivacyOption('private', 'Private', 'Only you can see your profile'),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrivacyOption(String value, String title, String description) {
    final isSelected = _selectedPrivacyMode == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPrivacyMode = value;
          _hasChanges = true;
        });
      },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0066FF).withOpacity(0.2) : Colors.black,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Color(0xFF0066FF) : Colors.grey[800]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Color(0xFF0066FF) : Colors.grey,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
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

  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Discard Changes?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Discard',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
