import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './features/productsearch/productsearch.ui.dart'; // Asegúrate de que la ruta sea correcta
import 'package:prizo/features/escaner/presentation/interfaz_scanner.dart';

void main() {
  runApp(const Prizo());
}

class Prizo extends StatelessWidget {
  const Prizo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PrizoState(),
      child: const MaterialApp(
        home: ProductSearchScreen(),
      ),
    );
  }
}

class PrizoState extends ChangeNotifier {
  var displayTest = 'Hello World';
}
