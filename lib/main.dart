import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/pantalla_inicio/presentation/pantalla_inicio_interfaz.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura la inicialización antes de ejecutar la app
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
        home: PantallaInicio(), // Aquí se cambia ListaCompraInterfaz por ProductSearchScreen
      ),
    );
  }
}

class PrizoState extends ChangeNotifier {
  var displayTest = 'Hello World';
}
