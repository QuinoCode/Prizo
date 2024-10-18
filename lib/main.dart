import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './features/lista_compra/presentation/lista_compra_interfaz.dart';

void main() {
  runApp(const Prizo());
}

class Prizo extends StatelessWidget 
{
  const Prizo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PrizoState(),
      child:  MaterialApp(
        home: ListaCompraInterfaz(displayText: 'Hello World'),
      ),
    );
  }
}
class PrizoState extends ChangeNotifier 
{
  var displayTest = 'Hello World';
}
