import 'package:flutter/material.dart';
import '../models/live_location.dart';
import '../services/location_service.dart';

/// Widget for controlling location sharing
class LocationSharingToggle extends StatefulWidget {
  final LocationService locationService;
  final String currentUserId;
  final String currentUserName;

  const LocationSharingToggle({
    Key? key,
    required this.locationService,
    required this.currentUserId,
    required this.currentUserName,
  }) : super(key: key);

  @override
  _LocationSharingToggleState createState() => _LocationSharingToggleState();
}

class _LocationSharingToggleState extends State<LocationSharingToggle> {
  bool _isSharing = false;
  LocationSharingSettings _settings = LocationSharingSettings();

  @override
  void initState() {
    super.initState();
    _settings = widget.locationService.getSettings();
    _isSharing = _settings.enabled;

    // Listen to settings updates
    widget.locationService.settingsStream.listen((settings) {
      if (mounted) {
        setState(() {
          _settings = settings;
          _isSharing = settings.enabled;
        });
      }
    });
  }

  Future<void> _toggleSharing(bool value) async {
    setState(() {
      _isSharing = value;
    });

    try {
      if (value) {
        await widget.locationService.startSharingLocation(
          userId: widget.currentUserId,
          userName: widget.currentUserName,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location sharing started'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await widget.locationService.stopSharingLocation();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location sharing stopped'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSharing = !value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to toggle location sharing'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationSettingsSheet(
        locationService: widget.locationService,
        currentSettings: _settings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isSharing
            ? Color(0xFF4CAF50).withOpacity(0.1)
            : Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSharing ? Color(0xFF4CAF50) : Colors.grey[700]!,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isSharing ? Icons.my_location : Icons.location_off,
            color: _isSharing ? Color(0xFF4CAF50) : Colors.grey,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Sharing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _isSharing
                      ? 'Your location is visible to friends'
                      : 'Share your location with friends',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _isSharing,
            onChanged: _toggleSharing,
            activeColor: Color(0xFF4CAF50),
            inactiveThumbColor: Colors.grey,
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.grey),
            onPressed: _showSettings,
            tooltip: 'Location settings',
          ),
        ],
      ),
    );
  }
}

/// Location settings bottom sheet
class LocationSettingsSheet extends StatefulWidget {
  final LocationService locationService;
  final LocationSharingSettings currentSettings;

  const LocationSettingsSheet({
    Key? key,
    required this.locationService,
    required this.currentSettings,
  }) : super(key: key);

  @override
  _LocationSettingsSheetState createState() => _LocationSettingsSheetState();
}

class _LocationSettingsSheetState extends State<LocationSettingsSheet> {
  late LocationSharingSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.currentSettings;
  }

  Future<void> _saveSettings() async {
    try {
      await widget.locationService.updateSettings(_settings);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Settings saved'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Location Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Privacy options
          Text(
            'Who can see your location?',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 12),
          
          _buildPrivacyOption(
            'All Friends',
            'Share with all your friends',
            LocationPrivacy.friendsOnly,
          ),
          _buildPrivacyOption(
            'Selected Friends',
            'Choose specific friends',
            LocationPrivacy.selectedFriends,
          ),
          _buildPrivacyOption(
            'Public',
            'Visible to everyone',
            LocationPrivacy.public,
          ),
          _buildPrivacyOption(
            'Nobody',
            'Don\'t share location',
            LocationPrivacy.none,
          ),

          SizedBox(height: 20),

          // Additional settings
          SwitchListTile(
            title: Text('Share Speed', style: TextStyle(color: Colors.white)),
            subtitle: Text('Show your speed to friends',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            value: _settings.shareSpeed,
            activeColor: Color(0xFF0066FF),
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(shareSpeed: value);
              });
            },
          ),
          
          SwitchListTile(
            title: Text('Share Direction', style: TextStyle(color: Colors.white)),
            subtitle: Text('Show your heading to friends',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            value: _settings.shareHeading,
            activeColor: Color(0xFF0066FF),
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(shareHeading: value);
              });
            },
          ),

          SizedBox(height: 20),

          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0066FF),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption(
    String title,
    String subtitle,
    LocationPrivacy privacy,
  ) {
    final isSelected = _settings.privacy == privacy;
    return GestureDetector(
      onTap: () {
        setState(() {
          _settings = _settings.copyWith(privacy: privacy);
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0066FF).withOpacity(0.2) : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF0066FF) : Colors.transparent,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
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
