import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(RiderMateApp());
}

class RiderMateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RiderMate',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Color(0xFF0066FF),
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Segoe UI',
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int points = 1250;
  double todayDistance = 23.5;
  int referralCount = 12;
  bool isRiding = false;
  int selectedTab = 0;

  List<RideHistory> rideHistory = [
    RideHistory('Route 1', 25.3, 45, DateTime.now().subtract(Duration(days: 1))),
    RideHistory('Route 2', 15.7, 32, DateTime.now().subtract(Duration(days: 2))),
    RideHistory('Route 3', 32.1, 58, DateTime.now().subtract(Duration(days: 3))),
  ];

  List<String> friends = ['Alex', 'Jordan', 'Sam', 'Casey'];
  List<Memory> memories = [
    Memory('Sunset View', 12.34, 77.56, 'Beautiful evening ride', 'public', 120),
    Memory('City Center', 12.97, 77.59, 'Great cycling spot', 'friends', 85),
    Memory('Park Trail', 13.05, 77.62, 'Scenic route', 'private', 0),
  ];

  void startRide() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RideScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RiderMate',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      '$points pts',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Navigation
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTab('Today', 0),
                  SizedBox(width: 10),
                  _buildTab('History', 1),
                  SizedBox(width: 10),
                  _buildTab('Friends', 2),
                  SizedBox(width: 10),
                  _buildTab('Memories', 3),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Content based on tab
            Expanded(
              child: SingleChildScrollView(
                child: selectedTab == 0
                    ? _buildTodayTab()
                    : selectedTab == 1
                        ? _buildHistoryTab()
                        : selectedTab == 2
                            ? _buildFriendsTab()
                            : _buildMemoriesTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0066FF) : Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTab() {
    return Column(
      children: [
        // Today's Stats Card
        Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0066FF), Color(0xFF004499)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                'Today',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '${todayDistance.toStringAsFixed(1)} km',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),

        // START RIDE BUTTON
        GestureDetector(
          onTap: startRide,
          child: Container(
            width: 300,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '🚀 START RIDE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 30),

        // Quick Stats
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Avg Speed', '28.5 km/h'),
              _buildStatCard('Max Speed', '52.3 km/h'),
              _buildStatCard('Calories', '245 kcal'),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Referral Card
        Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Color(0xFFFF6B35), width: 2),
          ),
          child: Column(
            children: [
              Text(
                '📱 Referral Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'RIDER2025XYZ',
                  style: TextStyle(
                    color: Color(0xFFFF6B35),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Referred: $referralCount friends | Earned: 600 pts',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Recent Rides',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ...rideHistory.map((ride) => _buildRideCard(ride)).toList(),
      ],
    );
  }

  Widget _buildFriendsTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Friends on Map',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        // Map Placeholder
        Container(
          margin: EdgeInsets.all(20),
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              '🗺️ LIVE MAP\n(Location of friends)',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Friends List',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ...friends.map((friend) => _buildFriendCard(friend)).toList(),
      ],
    );
  }

  Widget _buildMemoriesTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Location Memories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ...memories.map((memory) => _buildMemoryCard(memory)).toList(),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: Color(0xFF0066FF),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(RideHistory ride) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ride.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '${ride.distance.toStringAsFixed(1)} km • ${ride.duration} min',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Text(
            '${(ride.distance * 10).toInt()} pts',
            style: TextStyle(
              color: Color(0xFFFF6B35),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(String name) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFF0066FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name[0],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(
                name,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          Text(
            '📍 Live',
            style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard(Memory memory) {
    Color privacyColor = memory.privacy == 'public'
        ? Color(0xFF4CAF50)
        : memory.privacy == 'friends'
            ? Color(0xFF0066FF)
            : Colors.grey;
    String privacyIcon = memory.privacy == 'public'
        ? '🌍'
        : memory.privacy == 'friends'
            ? '👥'
            : '🔒';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: privacyColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                memory.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: privacyColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$privacyIcon ${memory.privacy}',
                  style: TextStyle(
                    color: privacyColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            memory.note,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📍 ${memory.lat.toStringAsFixed(2)}, ${memory.lon.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
              if (memory.privacy == 'public')
                Text(
                  '❤️ ${memory.likes}',
                  style: TextStyle(
                    color: Color(0xFFFF6B35),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class RideScreen extends StatefulWidget {
  @override
  _RideScreenState createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  double currentSpeed = 0;
  double distance = 0;
  double speedLimit = 60;
  int duration = 0;
  Timer? timer;
  bool isWarning = false;

  @override
  void initState() {
    super.initState();
    _startRide();
  }

  void _startRide() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        duration++;
        // Simulate GPS speed changes
        currentSpeed = 25 + (20 * sin(duration / 10)) + Random().nextDouble() * 5;
        if (currentSpeed < 0) currentSpeed = 0;
        distance += currentSpeed / 3600;

        // Check speed warning
        isWarning = currentSpeed > speedLimit;
      });
    });
  }

  void _addMemory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Add Memory',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Memory description',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                    child: Text('📸 Photo'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0066FF),
                    ),
                    child: Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sosAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFCC0000),
        title: Text(
          '🚨 SOS ACTIVATED',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Emergency alert sent to your contacts!\nLocation: Lat 12.97, Lon 77.59',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        timer?.cancel();
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Map Background
            Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  '🗺️ LIVE MAP\n(Google Maps Integration)',
                  style: TextStyle(fontSize: 24, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Speed Warning Banner
            if (isWarning)
              Positioned(
                top: 60,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Color(0xFFCC0000),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.white, size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'SLOW DOWN! Speed Limit: ${speedLimit.toStringAsFixed(0)}km/h',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Top Stats Bar
            Positioned(
              top: isWarning ? 120 : 60,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Speed', style: TextStyle(color: Colors.grey)),
                        Text(
                          '${currentSpeed.toStringAsFixed(1)} km/h',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Distance', style: TextStyle(color: Colors.grey)),
                        Text(
                          '${distance.toStringAsFixed(2)} km',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Time', style: TextStyle(color: Colors.grey)),
                        Text(
                          '${(duration ~/ 60)}:${(duration % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Control Panel
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Memory Button
                  GestureDetector(
                    onTap: _addMemory,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(0xFF0066FF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF0066FF).withOpacity(0.4),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 28),
                    ),
                  ),

                  // Music Button
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF6B35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.music_note, color: Colors.white, size: 28),
                  ),

                  // SOS Button (Big Red)
                  GestureDetector(
                    onTap: _sosAlert,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFFCC0000),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFCC0000).withOpacity(0.5),
                            blurRadius: 25,
                          ),
                        ],
                      ),
                      child: Icon(Icons.sos, color: Colors.white, size: 40),
                    ),
                  ),

                  // Friends Button
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.group, color: Colors.white, size: 28),
                  ),

                  // End Ride Button
                  GestureDetector(
                    onTap: () {
                      timer?.cancel();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('✅ Ride Saved! +${(distance * 10).toStringAsFixed(0)} points')),
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.stop_circle, color: Colors.white, size: 28),
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

class RideHistory {
  String name;
  double distance;
  int duration;
  DateTime date;

  RideHistory(this.name, this.distance, this.duration, this.date);
}

class Memory {
  String name;
  double lat;
  double lon;
  String note;
  String privacy; // 'private', 'friends', 'public'
  int likes;

  Memory(this.name, this.lat, this.lon, this.note, this.privacy, this.likes);
}
