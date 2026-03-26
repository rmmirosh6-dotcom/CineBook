import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../core/app_colors.dart';

class ARViewScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  const ARViewScreen({Key? key, this.data}) : super(key: key);

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> with SingleTickerProviderStateMixin {
  bool _isARMode = false;
  CameraController? _cameraController;
  late AnimationController _animationController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera init failed: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleARMode() {
    setState(() {
      _isARMode = !_isARMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedSeat = widget.data?['selectedSeat'] as String? ?? 'C4';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background: Camera or Solid Black
          if (_isARMode && _isCameraInitialized && _cameraController != null)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            )
          else
            Container(color: Colors.black),

          // 3D Hall Overlay
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: CinemaHallPainter(
                  rotationY: (math.sin(_animationController.value * math.pi * 2) * 0.1),
                  selectedSeat: selectedSeat,
                  isARMode: _isARMode,
                ),
              );
            },
          ),

          // UI Controls
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        style: IconButton.styleFrom(backgroundColor: Colors.black45),
                      ),
                      Text(
                        _isARMode ? 'AR VIEW' : '3D PREVIEW',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildToggleButton(
                        icon: Icons.threed_rotation,
                        label: '3D Preview',
                        isActive: !_isARMode,
                        onTap: () => setState(() => _isARMode = false),
                      ),
                      const SizedBox(width: 16),
                      _buildToggleButton(
                        icon: Icons.camera_alt,
                        label: 'Camera AR',
                        isActive: _isARMode,
                        onTap: _toggleARMode,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Permission Warning if fallback
          if (_isARMode && !_isCameraInitialized)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Camera not available or permission denied.\nShowing 3D overlay on dark background.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.black54,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white24, width: 1),
          boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 10)] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class CinemaHallPainter extends CustomPainter {
  final double rotationY;
  final String selectedSeat;
  final bool isARMode;

  CinemaHallPainter({
    required this.rotationY,
    required this.selectedSeat,
    required this.isARMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final perspective = 0.001; // Perspective factor

    // Setup projection function
    Offset project(double x, double y, double z) {
      // Apply rotation on Y axis
      double rx = x * math.cos(rotationY) - z * math.sin(rotationY);
      double rz = x * math.sin(rotationY) + z * math.cos(rotationY);
      
      // Depth perspective
      double scale = 1 / (rz * perspective + 1);
      return Offset(center.dx + rx * scale, center.dy + y * scale);
    }

    final hallPaint = Paint()
      ..color = isARMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade900
      ..style = PaintingStyle.fill;

    final wireframePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 1. Draw Hall Floor & Ceiling
    final floorPath = Path();
    floorPath.moveTo(project(-600, 400, 200).dx, project(-600, 400, 200).dy);
    floorPath.lineTo(project(600, 400, 200).dx, project(600, 400, 200).dy);
    floorPath.lineTo(project(400, 400, 2000).dx, project(400, 400, 2000).dy);
    floorPath.lineTo(project(-400, 400, 2000).dx, project(-400, 400, 2000).dy);
    floorPath.close();
    canvas.drawPath(floorPath, hallPaint);
    canvas.drawPath(floorPath, wireframePaint);

    final ceilingPath = Path();
    ceilingPath.moveTo(project(-600, -600, 200).dx, project(-600, -600, 200).dy);
    ceilingPath.lineTo(project(600, -600, 200).dx, project(600, -600, 200).dy);
    ceilingPath.lineTo(project(400, -600, 2000).dx, project(400, -600, 2000).dy);
    ceilingPath.lineTo(project(-400, -600, 2000).dx, project(-400, -600, 2000).dy);
    ceilingPath.close();
    canvas.drawPath(ceilingPath, hallPaint);

    // 2. Draw Screen at the far end
    final screenPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.blue, Colors.lightBlueAccent, Colors.white],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final screenPath = Path();
    screenPath.moveTo(project(-350, -200, 1950).dx, project(-350, -200, 1950).dy);
    screenPath.lineTo(project(350, -200, 1950).dx, project(350, -200, 1950).dy);
    screenPath.lineTo(project(350, 250, 1950).dx, project(350, 250, 1950).dy);
    screenPath.lineTo(project(-350, 250, 1950).dx, project(-350, 250, 1950).dy);
    screenPath.close();
    
    // Screen glow
    canvas.drawShadow(screenPath, Colors.blueAccent, 20, true);
    canvas.drawPath(screenPath, screenPaint);

    // 3. Draw Seats
    final int rows = 8;
    final int cols = 8;
    
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Skip aisles
        if (c == 3 || c == 4) continue;
        
        final seatId = '${String.fromCharCode(65 + r)}${c + 1}';
        final isSelected = seatId == selectedSeat;
        
        // Calculate 3D position
        // Row A is back (further), Row H is front (closer)
        // Adjusting so Row A is far, Row H is near
        double zPos = (rows - r) * 200.0 + 300; 
        double xPos = (c - 3.5) * 120.0;
        double yPos = 350.0; // Floor height

        final seatOffset = project(xPos, yPos, zPos);
        final seatSize = 40.0 * (1 / (zPos * perspective + 1));
        
        final seatPaint = Paint()
          ..color = isSelected 
              ? AppColors.primary 
              : Colors.blueGrey.withOpacity(isARMode ? 0.3 : 0.8)
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: seatOffset, width: seatSize * 2, height: seatSize * 1.5),
            Radius.circular(seatSize * 0.3),
          ),
          seatPaint,
        );

        if (isSelected) {
          // Highlight selected seat with glow
          final glowPaint = Paint()
            ..color = AppColors.primary.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
          canvas.drawCircle(seatOffset, seatSize * 3, glowPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CinemaHallPainter oldDelegate) {
    return oldDelegate.rotationY != rotationY || 
           oldDelegate.selectedSeat != selectedSeat || 
           oldDelegate.isARMode != isARMode;
  }
}
