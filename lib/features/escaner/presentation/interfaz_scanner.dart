import 'package:prizo/features/escaner/application/scanner_service.dart';
import 'package:flutter/material.dart';
import 'package:prizo/features/obtencion_producto/application/ean_finder.dart';

class ScannerInterface extends StatefulWidget {
	final String title;
	const ScannerInterface({super.key, required this.title});  

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
	   appBar: AppBar(
		   title: Text(widget.title),
		   centerTitle: true,
	   ),
	   body: Center(
		   child: SizedBox(
			   height: 200,
			   width: 350,
			   child: createScanner(context, eanFinder),
		   ),
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


