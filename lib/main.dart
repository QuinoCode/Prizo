import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prizo/features/productsearch/product_search_ui_updated.dart'; 
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
        home: ProductSearchScreen(),
      ),
    );
  }
}

class PrizoState extends ChangeNotifier {
  var displayTest = 'Hello World';
}
