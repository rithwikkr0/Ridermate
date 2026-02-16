import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_provider.dart';
import '../models/user_model.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';
import 'login_page.dart';

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.userProfile;

          if (user == null) {
            return Center(
              child: Text(
                'No user data available',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
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
                        image: user.profilePhoto != null
                            ? DecorationImage(
                                image: NetworkImage(user.profilePhoto!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: user.profilePhoto == null ? Color(0xFF0066FF) : null,
                      ),
                      child: user.profilePhoto == null
                          ? Center(
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
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
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // Name
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(height: 5),
                
                // Email
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                
                if (!authProvider.isEmailVerified)
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, size: 16, color: Colors.orange),
                          SizedBox(width: 5),
                          Text(
                            'Email not verified',
                            style: TextStyle(color: Colors.orange, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                SizedBox(height: 10),
                
                // Privacy Mode Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getPrivacyColor(user.privacyMode).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getPrivacyColor(user.privacyMode)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPrivacyIcon(user.privacyMode),
                        size: 16,
                        color: _getPrivacyColor(user.privacyMode),
                      ),
                      SizedBox(width: 5),
                      Text(
                        user.privacyMode.toUpperCase(),
                        style: TextStyle(
                          color: _getPrivacyColor(user.privacyMode),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Bio
                if (user.bio != null && user.bio!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      user.bio!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[300],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                SizedBox(height: 30),
                
                // Stats Section
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFF004499)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Riding Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Rides', user.totalRides.toString(), Icons.directions_bike),
                          _buildStatItem('Distance', '${user.totalDistance.toStringAsFixed(1)} km', Icons.route),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Points', user.totalPoints.toString(), Icons.stars),
                          _buildStatItem('Safety', user.safetyScore.toStringAsFixed(0), Icons.shield),
                        ],
                      ),
                      SizedBox(height: 15),
                      _buildStatItem('Streak', '${user.currentStreak} days', Icons.local_fire_department),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Account Info
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildInfoRow('Joined', DateFormat('MMM dd, yyyy').format(user.dateOfJoined)),
                      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                        _buildInfoRow('Phone', user.phoneNumber!),
                      _buildInfoRow('Language', user.preferredLanguage.toUpperCase()),
                    ],
                  ),
                ),
                
                SizedBox(height: 30),
                
                // Action Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EditProfilePage()),
                          );
                        },
                        icon: Icon(Icons.edit, color: Colors.white),
                        label: Text(
                          'Edit Profile',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0066FF),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                      
                      SizedBox(height: 15),
                      
                      OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        icon: Icon(Icons.logout, color: Colors.red),
                        label: Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPrivacyColor(String privacy) {
    switch (privacy.toLowerCase()) {
      case 'public':
        return Color(0xFF4CAF50);
      case 'friends-only':
      case 'friends':
        return Color(0xFF0066FF);
      case 'private':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getPrivacyIcon(String privacy) {
    switch (privacy.toLowerCase()) {
      case 'public':
        return Icons.public;
      case 'friends-only':
      case 'friends':
        return Icons.group;
      case 'private':
        return Icons.lock;
      default:
        return Icons.lock;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to logout?',
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
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            },
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
