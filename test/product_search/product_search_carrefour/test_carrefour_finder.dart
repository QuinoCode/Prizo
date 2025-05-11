import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/features/product_search/product_search_carrefour/application/carrefour_finder_service.dart';

void main() async {

  group('Carrefour_Finder Integration Test', () {
    test('should fetch products and map them correctly', () async {
      CarrefourFinderService finder = CarrefourFinderService();
      String query = "arandano";
      List<Producto> result = await finder.getProductList(query);
      expect(result, isA<List<Producto>>());
    });
  });

}
