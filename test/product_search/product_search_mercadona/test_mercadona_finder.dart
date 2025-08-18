import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/features/product_search/product_search_mercadona/application/mercadona_finder_service.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';

void main() async {

  group('Mercadona_Finder Integration Test', () {
    test('should fetch products and map them correctly', () async {
      MercadonaFinderService finder = MercadonaFinderService();
      String query = "ruffles";
      List<Producto> result = await finder.getProductList(query);
      print("Printeando a mi madre" + result.toString());
      for (Producto product in result) {
        print(product);
      }
      expect(result, isA<List<Producto>>());
    });
  });

}
