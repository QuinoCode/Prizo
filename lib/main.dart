import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prizo/features/productsearch/productsearch.ui.dart'; 
import 'package:prizo/shared/database/database_operations.dart';
import 'package:prizo/shared/application/barra_navegacion.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseOperations.instance.openOrCreateDB();
  runApp(const Prizo());
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
        home: BarraNavegacion(), // Aquí se cambia ListaCompraInterfaz por ProductSearchScreen
      ),
    );
  }
}

class PrizoState extends ChangeNotifier {
  var displayTest = 'Hello World';
}
