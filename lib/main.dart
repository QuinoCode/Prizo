import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/pantalla_inicio/presentation/barra_navegacion.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prizo/shared//database/database_operations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseOperations.instance.openOrCreateDB();
  await initializeDateFormatting('es_ES', null);
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
