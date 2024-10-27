
import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/features/obtencion_producto/domain/response_api_mercadona_data_model.dart';
import 'package:prizo/shared/data_entities/producto.dart';
import 'package:prizo/features/obtencion_producto/application/mercadona_finder_service.dart';

void main() async {
  group('Mercadona_Finder Integration Test', () {
    test('should fetch products and map them correctly', () async {
      // Arrange
      MercadonaFinderService finder = MercadonaFinderService();
      String query = "fabada";

      // Act
      MercadonaProduct? product = await finder.doHttpRequest(query);
      expect(product, isNotEmpty);
    });
  });
}