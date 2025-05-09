import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/pantalla_inicio/presentation/barra_navegacion.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prizo/shared//database/database_operations.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await DatabaseOperations.instance.deleteDB();
  await DatabaseOperations.instance.openOrCreateDB();
  await initializeDateFormatting('es_ES', null);
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
    return ChangeNotifierProvider(
      create: (context) => PrizoState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Opcional, para quitar la etiqueta de debug
        title: 'Prizo App',
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/home': (context) => BarraNavegacion()
        },
      ),
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
      body: Image.asset('assets/gifs/splash_screen_animation.gif', alignment: Alignment(-1, 0),)

    );
  }
}

class PrizoState extends ChangeNotifier {
  int _currentIndex = 0;
  String _searchQuery = "";
  int orderingWay = 0;

  int get currentIndex => _currentIndex;
  String get searchQuery => _searchQuery;

  void setIndex(int index, [String? query]) {
    _currentIndex = index;
    
    if (query!= null) {
      _searchQuery = query;
    }

    notifyListeners(); // Notify UI updates
  }
  void setOrderingWay(int newOrderingWay, [String? query]) {
    orderingWay = newOrderingWay;
    
    if (query!= null) {
      _searchQuery = query;
    }

    notifyListeners(); // Notify UI updates
  }
}
