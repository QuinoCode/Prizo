
import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/features/obtencion_producto/domain/response_api_carrefour_data_model.dart';
import 'package:http/http.dart' as http;
import 'package:prizo/shared/data_entities/producto.dart';
import 'package:prizo/features/obtencion_producto/application/carrefour_finder_service.dart';

void main() async {

  group('Carrefour_Finder Integration Test', () {
    test('should fetch products and map them correctly', () async {
      CarrefourFinderService finder = CarrefourFinderService();
      String query = "Sin gluten";
      List<Producto> result = await finder.getProductList(query);
      expect(result, isA<List<Producto>>());
    });
  });

}