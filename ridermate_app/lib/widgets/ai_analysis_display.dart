import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/ai_analysis.dart';

class AIAnalysisDisplay extends StatefulWidget {
  final AIAnalysis analysis;

  const AIAnalysisDisplay({
    Key? key,
    required this.analysis,
  }) : super(key: key);

  @override
  State<AIAnalysisDisplay> createState() => _AIAnalysisDisplayState();
}

class _AIAnalysisDisplayState extends State<AIAnalysisDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.analysis.safetyScore,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'AI Ride Analysis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Powered by RiderMate AI',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 30),

          // Safety Score
          _buildSafetyScore(),
          SizedBox(height: 30),

          // Performance Summary
          _buildSection(
            title: 'Performance Summary',
            icon: Icons.trending_up,
            content: widget.analysis.performanceSummary,
          ),
          SizedBox(height: 20),

          // Strengths
          if (widget.analysis.strengths.isNotEmpty) ...[
            _buildListSection(
              title: 'Strengths',
              icon: Icons.star,
              items: widget.analysis.strengths,
              color: Color(0xFF4CAF50),
            ),
            SizedBox(height: 20),
          ],

          // Improvements
          if (widget.analysis.improvements.isNotEmpty) ...[
            _buildListSection(
              title: 'Areas for Improvement',
              icon: Icons.lightbulb_outline,
              items: widget.analysis.improvements,
              color: Color(0xFFFF6B35),
            ),
            SizedBox(height: 20),
          ],

          // Suggestions
          if (widget.analysis.suggestions.isNotEmpty) ...[
            _buildListSection(
              title: 'AI Suggestions',
              icon: Icons.tips_and_updates,
              items: widget.analysis.suggestions,
              color: Color(0xFF0066FF),
            ),
            SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildSafetyScore() {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFF004499)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0066FF).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Safety Score',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 20),
          
          // Animated circular progress
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                CustomPaint(
                  size: Size(160, 160),
                  painter: _ScoreCirclePainter(
                    score: 100,
                    color: Colors.white24,
                    strokeWidth: 12,
                  ),
                ),
                // Animated score circle
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(160, 160),
                      painter: _ScoreCirclePainter(
                        score: _scoreAnimation.value,
                        color: _getScoreColor(_scoreAnimation.value),
                        strokeWidth: 12,
                      ),
                    );
                  },
                ),
                // Score text
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _scoreAnimation.value.toStringAsFixed(0),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '/ 100',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          
          // Score description
          Text(
            _getScoreDescription(widget.analysis.safetyScore),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFF0066FF), size: 24),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            content,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Color(0xFF4CAF50);
    if (score >= 60) return Color(0xFFFF6B35);
    return Color(0xFFCC0000);
  }

  String _getScoreDescription(double score) {
    if (score >= 90) return 'Excellent Safety!';
    if (score >= 80) return 'Great Safety!';
    if (score >= 70) return 'Good Safety';
    if (score >= 60) return 'Fair Safety';
    return 'Needs Improvement';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ScoreCirclePainter extends CustomPainter {
  final double score;
  final Color color;
  final double strokeWidth;

  _ScoreCirclePainter({
    required this.score,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * (score / 100);

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_ScoreCirclePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}
