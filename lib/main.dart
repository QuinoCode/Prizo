import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prizo/features/productsearch/product_search_ui.dart'; 
import 'package:prizo/shared/database/database_operations.dart';
import 'package:flutter/services.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseOperations.instance.openOrCreateDB();
  runApp(const Prizo());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent status bar
    statusBarIconBrightness: Brightness.dark, // Adjust icon color (optional)
  ));
}

class Prizo extends StatelessWidget {
  const Prizo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
      '/': (context) => SplashScreen(),
      '/home': (context) => ProductSearchScreen()
    },
      );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/gifs/dancing_rat.gif')
      )

    );
  }
}


class PrizoState extends ChangeNotifier {
  var displayTest = 'Hello World';
}
