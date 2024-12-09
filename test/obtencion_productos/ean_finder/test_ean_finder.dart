import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/shared/data_entities/producto.dart';
import 'package:prizo/features/obtencion_producto/application/ean_finder.dart';

void main() async {

  group('Carrefour_Finder Integration Test', () {
    test('should fetch products and map them correctly', () async {
      EanFinder finder = EanFinder();
      String query = "8410100021577";
      List<Producto?> result = await finder.getProductList(query);
      print("hasta aquí");
      expect(result, isA<List<Producto>>());
    });
  });

}
