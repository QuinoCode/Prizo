import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/features/comparacion_productos/application/comparacion_producto.dart';  // Import the file with the function
import 'package:prizo/shared/data_entities/producto.dart';  // Import the file with the function

void main() {
  test('My function should return correct output', () {
    // Arrangevoid main() {
  // Creating 3 instances of the Producto class
  Producto producto1 = Producto(
    id: '001',
    nombre: 'Leche',
    foto: 'leche.png',
    alergeno: 'Lactosa',
    precio: 1.50,
    tienda: 'Supermercado A',
  );

  Producto producto2 = Producto(
    id: '002',
    nombre: 'Pan',
    foto: 'pan.png',
    alergeno: 'Gluten',
    precio: 0.80,
    tienda: 'Panadería B',
  );

  Producto producto3 = Producto(
    id: '003',
    nombre: 'Jugo de Naranja',
    foto: 'jugo_naranja.png',
    alergeno: 'Ninguno',
    precio: 2.00,
    tienda: 'Tienda de Jugos C',
  );

    List<Producto> product_list = [producto1, producto2, producto3];
    var expectedOutput = 0.8;

    // Act
    var result = Comparacion_producto.obtenerProductoMasBarato(product_list)?.precio;

    // Assert
    expect(result, expectedOutput);
  });
}
