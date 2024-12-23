import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  test('Print database path', () async {
    String path = await getDatabasesPath();
    print('Database Path: $path');
  });
}

