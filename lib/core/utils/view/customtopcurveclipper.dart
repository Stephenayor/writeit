import 'package:flutter/cupertino.dart';

class CustomTopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Start from top left with a pronounced curve
    path.moveTo(0, 60);

    path.quadraticBezierTo(0, 30, 30, 10);

    // Continue with gentle curve to the right
    path.quadraticBezierTo(size.width * 0.3, 0, size.width * 0.7, 0);

    path.quadraticBezierTo(size.width * 0.9, 0, size.width, 10);

    path.lineTo(size.width, size.height);

    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
