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
    onDetect: (capture){
      final List<Barcode> barcodes = capture.barcodes;
      final Uint8List? image = capture.image;
      for (final barcode in barcodes) {
      print(barcode.rawValue ?? "No Data found in Barcode");
    }
      if (image != null) { showDialog(context: context, builder: (context) =>
      AlertDialog( title: Text("Barcode details: ${barcodes.first.rawValue}" ??
      "No data found in barcode"), content: Image(image:
      MemoryImage(image)),)); }
    }
);
  return scanner;
  
}

Future<List<Producto?>>  getProductFromScan(String ean) async {
  EanFinder finder = EanFinder();
  return await finder.getProductList(ean);
}
