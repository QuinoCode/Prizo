import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/features/product_search/product_search_consum/application/consum_finder_service.dart';

void main() async {
  group('Consum Integration Test', () {
    test('should fetch products and map them correctly', () async {
// Arrange
      ConsumFinderService finder = ConsumFinderService();
      String query = "Classic descafeinado";

// Act
      List<Producto> products = await finder.getProductList(query);

// Assert
      expect(products, isNotEmpty);
      for (var product in products) {
        print("Product ID: ${product.id}");
        print("Name: ${product.nombre}");
        print("Price: ${product.precio}");
        print("Brand: ${product.marca}");
        print("Image: ${product.foto}");
        print("Alergenos: Gluten-Free: ${product.alergenos[0]}, Lactose-Free: ${product.alergenos[1]}, Nuts-Free: ${product.alergenos[2]}");
        print("Hay oferta: ${product.oferta}");
        print("Precio oferta: ${product.precioOferta}");
        print("------------------------------------------------------------");

// Checks to validate the basic structure
        expect(product.id, isNotNull);
        expect(product.nombre, isNotNull);
        expect(product.precio, isA<double>());
        expect(product.alergenos, hasLength(3)); // Expect exactly three values for alergenos
      }
    });
  });
}
