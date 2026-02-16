import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/user_profile_service.dart';
import '../services/authentication_service.dart';
import '../models/user_settings.dart';
import '../models/privacy_settings.dart';
import '../utils/validation_utils.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserProfileService _profileService = UserProfileService();
  final AuthenticationService _authService = AuthenticationService();
  
  UserSettings? _settings;
  PrivacySettings? _privacy;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;
    
    if (userId != null) {
      try {
        final settings = await _profileService.getUserSettings(userId);
        final privacy = await _profileService.getPrivacySettings(userId);
        
        setState(() {
          _settings = settings;
          _privacy = privacy;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;
    
    if (userId != null) {
      try {
        await _profileService.updateUserSettings(userId, {key: value});
        await _loadSettings();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update setting'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updatePrivacy(String key, dynamic value) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;
    
    if (userId != null) {
      try {
        await _profileService.updatePrivacySettings(userId, {key: value});
        await _loadSettings();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update privacy setting'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Settings', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0066FF)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Account Settings
            _buildSection(
              'Account Settings',
              [
                _buildListTile(
                  'Change Password',
                  Icons.lock,
                  onTap: _showChangePasswordDialog,
                ),
                _buildListTile(
                  'Update Email',
                  Icons.email,
                  onTap: _showUpdateEmailDialog,
                ),
              ],
            ),
            
            // Privacy Settings
            if (_privacy != null)
              _buildSection(
                'Privacy Settings',
                [
                  _buildDropdownTile(
                    'Profile Visibility',
                    Icons.visibility,
                    _privacy!.profileVisibility,
                    ['public', 'friends', 'private'],
                    (value) => _updatePrivacy('profileVisibility', value),
                  ),
                  _buildDropdownTile(
                    'Location Sharing',
                    Icons.location_on,
                    _privacy!.locationSharing,
                    ['everyone', 'friends', 'none'],
                    (value) => _updatePrivacy('locationSharing', value),
                  ),
                  _buildDropdownTile(
                    'Memory Visibility Default',
                    Icons.camera_alt,
                    _privacy!.memoryVisibilityDefault,
                    ['public', 'friends', 'private'],
                    (value) => _updatePrivacy('memoryVisibilityDefault', value),
                  ),
                  _buildDropdownTile(
                    'Friend Requests',
                    Icons.person_add,
                    _privacy!.friendRequestSettings,
                    ['everyone', 'friends-of-friends', 'none'],
                    (value) => _updatePrivacy('friendRequestSettings', value),
                  ),
                ],
              ),
            
            // Notification Settings
            if (_settings != null)
              _buildSection(
                'Notification Settings',
                [
                  _buildSwitchTile(
                    'Email Notifications',
                    Icons.email,
                    _settings!.emailNotifications,
                    (value) => _updateSetting('emailNotifications', value),
                  ),
                  _buildSwitchTile(
                    'Push Notifications',
                    Icons.notifications,
                    _settings!.pushNotifications,
                    (value) => _updateSetting('pushNotifications', value),
                  ),
                  _buildDropdownTile(
                    'Notification Frequency',
                    Icons.schedule,
                    _settings!.notificationFrequency,
                    ['realtime', 'daily', 'weekly'],
                    (value) => _updateSetting('notificationFrequency', value),
                  ),
                ],
              ),
            
            // Preferences
            if (_settings != null)
              _buildSection(
                'Preferences',
                [
                  _buildDropdownTile(
                    'Language',
                    Icons.language,
                    _settings!.language,
                    ['en', 'es', 'fr', 'de', 'it'],
                    (value) => _updateSetting('language', value),
                  ),
                  _buildDropdownTile(
                    'Theme',
                    Icons.palette,
                    _settings!.theme,
                    ['light', 'dark', 'auto'],
                    (value) => _updateSetting('theme', value),
                  ),
                  _buildDropdownTile(
                    'Units',
                    Icons.straighten,
                    _settings!.units,
                    ['km', 'miles'],
                    (value) => _updateSetting('units', value),
                  ),
                  _buildDropdownTile(
                    'Map Style',
                    Icons.map,
                    _settings!.preferredMapStyle,
                    ['standard', 'satellite', 'hybrid'],
                    (value) => _updateSetting('preferredMapStyle', value),
                  ),
                ],
              ),
            
            // Danger Zone
            _buildSection(
              'Danger Zone',
              [
                _buildListTile(
                  'Delete Account',
                  Icons.delete_forever,
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: _showDeleteAccountDialog,
                ),
              ],
            ),
            
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(
    String title,
    IconData icon, {
    Color? textColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Color(0xFF0066FF)),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.white),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF0066FF)),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFF0066FF),
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    IconData icon,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF0066FF)),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: Colors.grey[900],
        style: TextStyle(color: Colors.white),
        underline: Container(),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Change Password',
          style: TextStyle(color: Colors.white),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0066FF)),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0066FF)),
                  ),
                ),
                validator: ValidationUtils.validatePasswordField,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await _authService.changePassword(
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password changed successfully'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Change', style: TextStyle(color: Color(0xFF0066FF))),
          ),
        ],
      ),
    );
  }

  void _showUpdateEmailDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Update Email',
          style: TextStyle(color: Colors.white),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'New Email',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0066FF)),
                  ),
                ),
                validator: ValidationUtils.validateEmailField,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0066FF)),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await _authService.updateEmail(
                    newEmail: emailController.text.trim(),
                    password: passwordController.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Verification email sent to new address'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Update', style: TextStyle(color: Color(0xFF0066FF))),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Delete Account',
          style: TextStyle(color: Colors.red),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This action cannot be undone. All your data will be permanently deleted.',
                style: TextStyle(color: Colors.grey[300]),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final userId = authProvider.firebaseUser?.uid;
                  
                  if (userId != null) {
                    await _profileService.deleteUserAccount(userId);
                    await _authService.deleteAccount(passwordController.text);
                    
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => LoginPage()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
