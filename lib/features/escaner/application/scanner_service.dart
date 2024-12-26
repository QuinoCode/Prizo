import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:prizo/features/obtencion_producto/application/ean_finder.dart';
import 'package:prizo/features/obtencion_producto/application/finder_wrapper.dart';
import 'package:prizo/shared/data_entities/producto.dart';
import 'package:prizo/features/escaner/presentation/interfaz_scanner.dart';


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
        print("------------Successfully scanned!--------------------");
        lockOpen = true;
      }
    }
);
  return scanner;
  
}

Future<void> detected(capture, BuildContext context, EanFinder eanFinder) async {
      final List<Barcode> barcodes = capture.barcodes;
      final Uint8List? image = capture.image;
      List<Producto?>? products;
      for (final barcode in barcodes) {
        if (image != null) { 
          showDialog(context: context, builder: (context) =>
            feedbackSuccessfulScan(image)
          ); 
        }
        products = await getProductFromScan(context, barcode.rawValue, eanFinder);
        if (products == null) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: const Text("No se encontró el artículo"),
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
        else { 
          showDialog(context: context, builder: (context) =>
            createAlertDialog(products!, image!)
          ); 
        };
        if (products == null) {print("No se encontró el producto en ningún supermercado");}
      }
}
AlertDialog feedbackSuccessfulScan(Uint8List image){
  return AlertDialog(title: const Text("Escaneado completo"), content: Image(image: MemoryImage(image)));
}
AlertDialog createAlertDialog(List<Producto?> products, Uint8List image){
  return products.every((product) => product == null) ? AlertDialog(
    title: const Text("No se encontró el producto"),
    content: const Text(":(", textAlign: TextAlign.center,)
  ) : AlertDialog(
    title: const Text("Productos"),
    content: Column (
      mainAxisSize: MainAxisSize.min,
    children: products
      .where((product) => product != null)
      .map((product) => Row(
        children: [
          Text("${product!.tienda}:"),
          TextButton(
            onPressed: (){
              //TODO: addItem to lista compra
              //TODO: close stuff
            },
            child:
              Text("${product.precioOferta}")
          ),
        ],
      )
      ).toList(),
    )
  );
}

Future<List<Producto?>?>  getProductFromScan(BuildContext context, String? ean, EanFinder eanFinder) async {
  if (ean == null) return null;
  return await eanFinder.getProductList(ean);
}
