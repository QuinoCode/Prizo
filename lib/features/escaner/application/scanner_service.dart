import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


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
