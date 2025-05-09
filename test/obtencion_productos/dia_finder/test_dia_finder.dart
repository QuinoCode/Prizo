import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/features/obtencion_producto/application/dia_finder_service.dart';

void main() async {
  group('DiaFinder Integration Test', () {
    test('should fetch products and map them correctly', () async {
      // Arrange
      DiaFinderService finder = DiaFinderService();
      String query = "coca cola";

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
        print("Oferta: ${product.oferta}");
        print("Precio oferta: ${product.precioOferta}");
        print("Alergenos: Gluten-Free: ${product.alergenos[0]}, Lactose-Free: ${product.alergenos[1]}, Nuts-Free: ${product.alergenos[2]}");
        print("------------------------------------------------------------");

        // Checks to validate the basic structure
        expect(product.id, isNotNull);
        expect(product.nombre, isNotNull);
        expect(product.precio, isA<double>());
        expect(product.alergenos, hasLength(3)); // Expect exactly three values for alergenos
        expect(product.precioOferta, isA<double>());
        expect(product.oferta, isA<bool>());
      }
    });
  });
}