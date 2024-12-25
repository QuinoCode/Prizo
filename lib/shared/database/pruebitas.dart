import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:prizo/shared/database/database_operations.dart';

void main() {
  test('Print database path', () async {
    await DatabaseOperations.instance.openOrCreateDB();
    final Database data = DatabaseOperations.instance.prizoDatabase;
    
    print(getDatabasesPath());


  });
}

