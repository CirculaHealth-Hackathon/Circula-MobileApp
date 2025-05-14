import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RipplePainter extends CustomPainter {
  final double radius;
  final LatLng center;
  final GoogleMapController? mapController;

  RipplePainter(
      {required this.radius,
      required this.center,
      required this.mapController});

  @override
  void paint(Canvas canvas, Size size) {
    if (mapController == null) return;

    mapController!.getScreenCoordinate(center).then((screenCoord) {
      final Offset screenPoint =
          Offset(screenCoord.x.toDouble(), screenCoord.y.toDouble());
      final Paint circlePaint = Paint()
        ..color = Colors.blue.withOpacity(1 - (radius / 80))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(screenPoint, radius, circlePaint);
    });
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) => true;
}
