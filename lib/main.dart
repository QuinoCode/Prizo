import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/DAO/lista_compra_DAO.dart';
import 'package:prizo/shared/data_entities/DAO/lista_favoritos_DAO.dart';
import 'package:prizo/shared/data_entities/DAO/producto_DAO.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:provider/provider.dart';
import 'package:prizo/features/productsearch/productsearch.ui.dart'; 
import 'package:prizo/shared/database/database_operations.dart';


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
      child: const MaterialApp(
        home: ProductSearchScreen(), // Aquí se cambia ListaCompraInterfaz por ProductSearchScreen
      ),
    );
  }
}

class PrizoState extends ChangeNotifier {
  var displayTest = 'Hello World';
}
