import 'package:prizo/features/escaner/application/scanner_service.dart';
import 'package:flutter/material.dart';

class ScannerInterface extends StatefulWidget {
	final String title;
	const ScannerInterface({super.key, required this.title});  

	@override
	State<ScannerInterface> createState() => _ScannerInterfaceState();
}

class _ScannerInterfaceState extends State<ScannerInterface> {
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
					 child: createScanner(context),
				 ),
			 ),
		 );
	 }
}

