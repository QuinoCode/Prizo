import 'package:flutter/material.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/features/product_search/obtencion_producto/application/ean_finder.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/database/database_operations.dart';
import 'package:sqflite/sqflite.dart';



class ScannerInterface extends StatefulWidget {

  const ScannerInterface({super.key});

  @override
  State<ScannerInterface> createState() => _ScannerInterfaceState();
}

class _ScannerInterfaceState extends State<ScannerInterface> {
  late EanFinder eanFinder;
  bool _isBlueFilterVisible = false;
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
            left: (MediaQuery.of(context).size.width - MediaQuery.of(context).size.width * 0.65) / 2,
            top: MediaQuery.of(context).size.height * 0.67,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.65,
              height: MediaQuery.of(context).size.height * 0.2 ,
              child:  Text(
                'Coloca el código de barras\ndentro del recuadro superior',
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: MediaQuery.of(context).size.shortestSide * 0.04293,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF121212),
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
                border: Border(bottom: BorderSide(color: Color(0xFF95B3FF), width: 2.0))
              ),
              child:  Stack(
                children: [
                    Align(
                    alignment: const Alignment(0,0.6),
                    child:  Text(
                      'Escanear',
                      style:  TextStyle(
                        fontFamily: 'Geist',
                        fontSize: MediaQuery.of(context).size.shortestSide * 0.0644,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF121212),
                      ),
                    ),
                  ),

                  // Exit button
                  Positioned(
                    child: Align(
                      alignment: const Alignment(0.8, 0.55),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.084,
                        height: MediaQuery.of(context).size.width * 0.084,
                        child: DiagonalCrossButton(
                          size: MediaQuery.of(context).size.width * 0.070,
                          strokeWidth: 2.5,
                          color: Color(0xFF121212),
                          onPressed: (){
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if(_isBlueFilterVisible)
            Positioned.fill(child: Container(color: Color(0xFF95B3FF).withOpacity(0.7)))
          
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
  MobileScanner createScanner(BuildContext context, EanFinder eanFinder) {
    bool lockOpen = true;
    MobileScanner scanner = MobileScanner(
      controller: MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      returnImage: true
      ),
      onDetect:(capture) async{
        if (lockOpen){
          lockOpen = false;
          await detected(capture, context, eanFinder);
          lockOpen = true;
        }
      }
    );
    return scanner;
    
  }

  Future<void> detected(capture, BuildContext context, EanFinder eanFinder) async {
        final List<Barcode> barcodes = capture.barcodes;
        List<Producto?>? products;
        for (final barcode in barcodes) {
          if (barcode.rawValue != null) { 
              feedbackSuccessfulScan();
          }
          products = await getProductFromScan(context, barcode.rawValue, eanFinder);
          if (products == null) {
            turnFilterOff();
            await showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("No se encontró el producto"),
                  content: const Text(":(", textAlign: TextAlign.center,),
                );
              },
            );
          }
          else { 
           bool  everyProductIsNull = products.every((product) => product == null);
           if (everyProductIsNull){
              await showDialog(context: context,barrierColor: Colors.transparent, builder: (context) => 
                AlertDialog(
                      title: const Text("No se encontró el producto"),
                      content: const Text(":(", textAlign: TextAlign.center,)
                    ),
              );
              turnFilterOff();
           }
           else {
             await showDialog(context: context, barrierColor: Colors.transparent, builder: (context) =>
                createAlertDialog(products!, context)
             ); 
              turnFilterOff();
            };
          }
        }
  }
  void feedbackSuccessfulScan(){
    setState(() {
      _isBlueFilterVisible = true;
    });
  }
  void turnFilterOff(){
    setState(() {
      _isBlueFilterVisible = false;
    });
  }

   createAlertDialog(List<Producto?> products, BuildContext context){
    return  Dialog(
      backgroundColor: Colors.white,
        insetPadding: EdgeInsets.zero,
      child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.12 + //Base height
          products.where((product) => product !=null).length * MediaQuery.of(context).size.height * 0.072,
          //height: MediaQuery.of(context).size.height * 0.37,
        child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment(-0.9,0.53),
                      //child: BackButton(
                      //  size: MediaQuery.of(context).size.width * 0.070,
                      //  color: Color(0xFF121212),
                      //  strokeWidth: 2.6,
                      //  onPressed: (){
                      //    Navigator.pop(context);
                      //  },
                      //),
                      child: SizedBox(child: Image.asset(
                        'assets/icons/arrow.png'),
                        width: MediaQuery.of(context).size.width * 0.070,
                      )
                    ),
                    Positioned(
                      left: MediaQuery.of(context).size.width *0.145,
                      top: MediaQuery.of(context).size.height *0.025,
                      child: Text(
                        "Elegir supermercado",
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: MediaQuery.of(context).size.shortestSide * 0.065,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    )
                  ],
                ),
              ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
              Align(
                 alignment: Alignment.center,
                 child: Column (
                   mainAxisSize: MainAxisSize.min,
                   children: products
                     .where((product) => product != null)
                     .map((product) => _supermarketAddProductButton(context, product!)
                     ).toList()
                   .expand((widget) => [widget, SizedBox(height: MediaQuery.of(context).size.height * 0.012,)])
                   .toList(),
                 ),
              ),
            ],
        ),
      )
      );
  }

  Widget _supermarketAddProductButton(BuildContext context, Producto producto){
    bool isPressed = false;

    return StatefulBuilder(
      builder: (context, setState){
         return SizedBox(
          width: MediaQuery.of(context).size.width * 0.71,
          height: MediaQuery.of(context).size.height * 0.06,
          child: GestureDetector(
            onPanStart: (_){
              setState((){
                isPressed = true;
              });
            },
            onPanCancel: (){
              setState((){
                isPressed = false;
              });
            },
            onPanEnd: (_){
              Navigator.of(context).pop();
              ListaCompraService listaCompraService = ListaCompraService();
              listaCompraService.DB_annadirProducto(producto);
              setState((){
                isPressed = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isPressed ? Color(0xFF95B3FF) : Colors.white,
                border: Border.all(color: Color(0xFF95B3FF)),
                borderRadius: BorderRadius.circular(40)
              ),
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width * 0.035),
                    Text(
                      producto.tienda.substring(0,1).toUpperCase() + producto.tienda.substring(1).toLowerCase(),
                      style: TextStyle(
                        fontFamily: 'Geist',
                        color: Color(0xFF121212),
                        fontSize: MediaQuery.of(context).size.shortestSide * 0.045
                      )
                    ),
                    Spacer(),
                    Text("${producto.precioOferta}€",
                      style: TextStyle(
                        fontFamily: 'Geist',
                        color:Color(0xFF504F4F),
                        fontSize: MediaQuery.of(context).size.shortestSide * 0.03375
                      )
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.035)
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
    
  }


  Future<List<Producto?>?>  getProductFromScan(BuildContext context, String? ean, EanFinder eanFinder) async {
    if (ean == null) return null;
    return await eanFinder.getProductList(ean);
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
  late Size _size;

  DiagonalCrossPainter({
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _size = size;
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Ensures rounded ends for the lines
    Paint paintBG = Paint()..color = Colors.transparent;

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paintBG);

    // Draw diagonal cross from top-left to bottom-right
    canvas.drawLine(
      Offset(size.width*0.2, size.height *0.2), // Start at top-left
      Offset(size.width*0.8, size.height *0.8), // End at bottom-right
      paint,
    );

    // Draw diagonal cross from top-right to bottom-left
    canvas.drawLine(
      Offset(size.width *0.8, size.width*0.2), // Start at top-right
      Offset(size.width*0.2, size.height *0.8), // End at bottom-left
      paint,
    );
  }
   @override
  bool hitTest(Offset position) {
    // Check if the tap is inside the bounds of the shape
    double size = _size.width; // Example size, use your own logic for this
    if (position.dx >= 0 && position.dx <= size && position.dy >= 0 && position.dy <= size) {
      return true;
    }
    return false;
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint unless the parameters change
  }
}



//Class for the backButton
class BackButton extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;
  final VoidCallback onPressed;

  const BackButton({
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
        painter: BackButtonPainter(
          strokeWidth: strokeWidth,
          color: color,
        ),
      ),
    );
  }
}

class BackButtonPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  late Size _size;

  BackButtonPainter({
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _size = size;
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Ensures rounded ends for the lines
    Paint paintBG = Paint()..color = Colors.transparent;

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paintBG);

    // Draw diagonal top line of the arrow
    canvas.drawLine(
      Offset(size.width * 0.30, size.height * 0.2), // Start at top-left
      Offset(size.width * 0.0, size.height * 0.5), // End at bottom-right
      paint,
    );
    // Draw diagonal bottom line of the arrow
    canvas.drawLine(
      Offset(size.width * 0.30, size.height * 0.8), // Start at top-left
      Offset(size.width * 0.0, size.height * 0.5), // End at bottom-right
      paint,
    );
    // Draw horizontal line of the arrow
    canvas.drawLine(
      Offset(size.width * 0.0 , size.height * 0.5), // Start at top-right
      Offset(size.width* 0.8, size.height * 0.5), // End at bottom-left
      paint,
    );
  }
   @override
  bool hitTest(Offset position) {
    // Check if the tap is inside the bounds of the shape
    double size = _size.width; // Example size, use your own logic for this
    if (position.dx >= 0 && position.dx <= size && position.dy >= 0 && position.dy <= size) {
      return true;
    }
    return false;
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint unless the parameters change
  }
}
