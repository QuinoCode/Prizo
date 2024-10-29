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
    precio: 1.50,
    tienda: 'Supermercado A',
    alergenos: [false, true, false],
    precioMedida: 0.5,
    marca: "hacendado",
  );

  Producto producto2 = Producto(
    id: '002',
    nombre: 'Pan',
    foto: 'pan.png',
    precio: 0.80,
    tienda: 'Panadería B',
    alergenos: [false, true, false],
    precioMedida: 0.5,
    marca: "hacendado",
  );

  Producto producto3 = Producto(
    id: '003',
    nombre: 'Jugo de Naranja',
    foto: 'jugo_naranja.png',
    precio: 2.00,
    tienda: 'Tienda de Jugos C',
    alergenos: [false, true, false],
    precioMedida: 0.5,
    marca: "hacendado",
  );

    List<Producto> product_list = [producto1, producto2, producto3];
    var expectedOutput = 0.8;

    // Act
    var result = Comparacion_producto.obtenerProductoMasBarato(product_list)?.precio;

    // Assert
    expect(result, expectedOutput);
  });
}
