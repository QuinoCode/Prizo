import 'package:prizo/features/escaner/application/scanner_service.dart';
import 'package:flutter/material.dart';
import 'package:prizo/features/obtencion_producto/application/ean_finder.dart';



class ScannerInterface extends StatefulWidget {

  const ScannerInterface({super.key});

  @override
  State<ScannerInterface> createState() => _ScannerInterfaceState();
}

class _ScannerInterfaceState extends State<ScannerInterface> {
  late EanFinder eanFinder;
  @override
  void initState(){
    super.initState();
    eanFinder = EanFinder(onError: noProductFoundOnEANDatabase);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background scanner (video)
          Align(
            alignment: const Alignment(0, 0),
            child: createScanner(context, eanFinder),
          ),
          // White overlay
          Align(
            alignment: const Alignment(0, 0),
            child: ClipPath(
              clipper: InvertedClipper(),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ),
          // Scanner box
          Stack(
            children: [
              //Top left marker
              Positioned(
                left: MediaQuery.of(context).size.width * 0.15,
                top: MediaQuery.of(context).size.height * 0.4225,
                child: DiagonalHalfSquare(
                  width: MediaQuery.of(context).size.width * 0.08,
                  height: MediaQuery.of(context).size.width * 0.08,
                  strokeWidth: MediaQuery.of(context).size.shortestSide * 0.015,
                  topColor: const Color(0xFF95B3FF),
                  leftColor: const Color(0xFF95B3FF),
                  bottomColor: Colors.transparent,
                  rightColor: Colors.transparent,
                ),
              ),
              //Bottom left marker
              Positioned(
                left: MediaQuery.of(context).size.width * 0.15,
                top: MediaQuery.of(context).size.height * 0.540,
                child: DiagonalHalfSquare(
                  width: MediaQuery.of(context).size.width * 0.08,
                  height: MediaQuery.of(context).size.width * 0.08,
                  strokeWidth: MediaQuery.of(context).size.shortestSide * 0.015,
                  topColor: Colors.transparent,
                  leftColor: const Color(0xFF95B3FF),
                  bottomColor: const Color(0xFF95B3FF),
                  rightColor: Colors.transparent,
                ),
              ),
              //Top right marker
              Positioned(
                left: MediaQuery.of(context).size.width * 0.765,
                top: MediaQuery.of(context).size.height * 0.4225,
                child: DiagonalHalfSquare(
                  width: MediaQuery.of(context).size.width * 0.08,
                  height: MediaQuery.of(context).size.width * 0.08,
                  strokeWidth: MediaQuery.of(context).size.shortestSide * 0.015,
                  topColor: const Color(0xFF95B3FF),
                  leftColor: Colors.transparent,
                  bottomColor: Colors.transparent,
                  rightColor: const Color(0xFF95B3FF),
                ),
              ),
              //Bottom right marker
              Positioned(
                left: MediaQuery.of(context).size.width * 0.765,
                top: MediaQuery.of(context).size.height * 0.540,
                child: DiagonalHalfSquare(
                  width: MediaQuery.of(context).size.width * 0.08,
                  height: MediaQuery.of(context).size.width * 0.08,
                  strokeWidth: MediaQuery.of(context).size.shortestSide * 0.015,
                  topColor: Colors.transparent,
                  leftColor: Colors.transparent,
                  bottomColor: const Color(0xFF95B3FF),
                  rightColor: const Color(0xFF95B3FF),
                ),
              ),
            ],
          ),
          //Text under the scanner
          Positioned(
            left: (MediaQuery.of(context).size.width - MediaQuery.of(context).size.width * 0.5) / 2,
            top: MediaQuery.of(context).size.height * 0.67,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.2 ,
              child:  Text(
                'Coloca el código de barras dentro del recuadro superior',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: MediaQuery.of(context).size.shortestSide * 0.037,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.12,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFF95B3FF), width: 2.5), )
                
              ),
              child:  Stack(
                children: [
                    Align(
                    alignment: const Alignment(0,0.6),
                    child:  Text(
                      'Escanear',
                      style:  TextStyle(
                        fontFamily: 'Geist',
                        fontSize: MediaQuery.of(context).size.shortestSide * 0.065,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF121212),
                      ),
                    ),
                  ),

                  // Exit button
                  Positioned(
                    child: Align(
                      alignment: const Alignment(0.8, 0.55),
                      child: DiagonalCrossButton(
                        size: MediaQuery.of(context).size.width * 0.07,
                        strokeWidth: 2.5,
                        color: Colors.black,
                        onPressed: (){print("Works");},
                      ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  void noProductFoundOnEANDatabase(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
	return AlertDialog(
	  title: const Text("Error"),
	  content: Text(message),
	  actions: [
	    TextButton(
	      child: const Text("OK"),
	      onPressed: () {
		Navigator.of(context).pop(); // Close the dialog
	      },
	    ),
	  ],
	);
      },
    );
  }
}


class InvertedClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size){
    //Dimensions for the cutout in the middle
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    final double rectWidth = screenWidth * 0.80;
    final double rectHeight = screenHeight * 0.20;

    //Position of the cutout in the middle
    final double left = (screenWidth - rectWidth) / 2;
    final double top = (screenHeight - rectHeight) / 2;
    final double right = left + rectWidth;
    final double bottom = top + rectHeight;

    return Path.combine(
      PathOperation.difference,
      Path()..addRect(
        Rect.fromLTWH(0, 0, size.width, size.height)
      ),
      Path()..addRRect(
        RRect.fromLTRBR(
          left,
          top,
          right,
          bottom,
          const Radius.circular(20)
        )
      )
  );
    
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;

}

class DiagonalHalfSquare extends StatelessWidget {
  final double width;
  final double height;
  final double strokeWidth;
  final Color topColor;
  final Color leftColor;
  final Color bottomColor;
  final Color rightColor;

  const DiagonalHalfSquare({
    Key? key,
    required this.width,
    required this.height,
    required this.strokeWidth,
    required this.topColor,
    required this.leftColor,
    required this.bottomColor,
    required this.rightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: DiagonalHalfSquarePainter(
        strokeWidth: strokeWidth,
        topColor: topColor,
        leftColor: leftColor,
        bottomColor: bottomColor,
        rightColor: rightColor,
      ),
    );
  }
}

class DiagonalHalfSquarePainter extends CustomPainter {
  final double strokeWidth;
  final Color topColor;
  final Color leftColor;
  final Color bottomColor;
  final Color rightColor;

  DiagonalHalfSquarePainter({
    required this.strokeWidth,
    required this.topColor,
    required this.leftColor,
    required this.bottomColor,
    required this.rightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round // This ensures the ends are rounded
      ..strokeWidth = strokeWidth;

    // Top side
    if (topColor != Colors.transparent) {
      paint.color = topColor;
      canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), paint);
    }

    // Left side
    if (leftColor != Colors.transparent) {
      paint.color = leftColor;
      canvas.drawLine(const Offset(0, 0), Offset(0, size.height), paint);
    }

    // Bottom side
    if (bottomColor != Colors.transparent) {
      paint.color = bottomColor;
      canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);
    }

    // Right side
    if (rightColor != Colors.transparent) {
      paint.color = rightColor;
      canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), paint);
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class DiagonalCrossButton extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;
  final VoidCallback onPressed;

  const DiagonalCrossButton({
    Key? key,
    required this.size,
    required this.strokeWidth,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CustomPaint(
        size: Size(size, size), // Size of the button
        painter: DiagonalCrossPainter(
          strokeWidth: strokeWidth,
          color: color,
        ),
      ),
    );
  }
}

class DiagonalCrossPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;

  DiagonalCrossPainter({
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Ensures rounded ends for the lines

    // Draw diagonal cross from top-left to bottom-right
    canvas.drawLine(
      const Offset(0, 0), // Start at top-left
      Offset(size.width, size.height), // End at bottom-right
      paint,
    );

    // Draw diagonal cross from top-right to bottom-left
    canvas.drawLine(
      Offset(size.width, 0), // Start at top-right
      Offset(0, size.height), // End at bottom-left
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint unless the parameters change
  }
}


