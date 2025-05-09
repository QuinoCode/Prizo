import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/features/obtencion_producto/application/ean_finder.dart';

void main() async {

  group('Ean finder test', () {
    test('should fetch products and map them correctly', () async {
      EanFinder finder = EanFinder();
      String query = "8413164020210";
      List<Producto?>? result = await finder.getProductList(query);
      print("hasta aquí");
      expect(result, isA<List<Producto?>>());
    });
  });

}
