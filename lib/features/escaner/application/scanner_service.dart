import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:prizo/features/obtencion_producto/application/ean_finder.dart';
import 'package:prizo/features/obtencion_producto/application/finder_wrapper.dart';
import 'package:prizo/shared/data_entities/producto.dart';


MobileScanner createScanner(BuildContext context) {
   MobileScanner scanner = MobileScanner(
  controller: MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: true
    ),
    onDetect:(capture){detected(capture, context);}
);
  return scanner;
  
}

//TODO Make some kind of feedback in order for the user to know if something successfully scanned and we're waiting just for the http process to resolve
void detected(capture, context) async {
      final List<Barcode> barcodes = capture.barcodes;
      final Uint8List? image = capture.image;
      List<Producto?>? products;
      for (final barcode in barcodes) {
        products = await getProductFromScan(barcode.rawValue);
        if (products == null) {print("No se encontró el producto en ningún supermercado");}
      }
      if (image != null) { 
        showDialog(context: context, builder: (context) =>
          createAlertDialog(products!, image)
        ); 
      }
}
AlertDialog createAlertDialog(List<Producto?> products, Uint8List image){
  String nonNullProducts = ""; 
  for (int i = 0; i < products.length; i++){
    if (products[i] != null) {nonNullProducts += "${products[i]!.tienda}: ${products[i]!.precio} \n";}
  }

  if (nonNullProducts.isEmpty) {nonNullProducts = "No products were found";}
  return AlertDialog(title: const Text("Precio productos"), content: Column(
    children: [
      Text(nonNullProducts),
      Image(image: MemoryImage(image))
    ],
  ));
}

Future<List<Producto?>?>  getProductFromScan(String? ean) async {
  if (ean == null) return null;
  EanFinder finder = EanFinder();
  return await finder.getProductList(ean);
}
