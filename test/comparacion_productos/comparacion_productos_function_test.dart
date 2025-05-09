import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/features/comparacion_productos/application/comparacion_producto.dart';  // Import the file with the function
import 'package:prizo/shared/data_entities/models/producto.dart';  // Import the file with the function

void main() {
  test('My function should return correct output', () {
    // Arrangevoid main() {
  // Creating 3 instances of the Producto class
  Producto producto1 = Producto(
    id: '001',
    nombre: 'Leche',
    foto: 'leche.png',
    alergenos: [false,true,false],
    precio: 1.50,
    tienda: 'Supermercado A',
    precioMedida: 10,
    marca: '',
    categoria: 'leche',
    oferta: false,
    precioOferta: 0.0,
  );

  Producto producto2 = Producto(
    id: '002',
    nombre: 'Pan',
    foto: 'pan.png',
    alergenos:[true, false, false],
    precio: 0.80,
    tienda: 'Panadería B',
    precioMedida: 10,
    marca: '',
    categoria: 'pan',
    oferta: false,
    precioOferta: 0.0,
  );

  Producto producto3 = Producto(
    id: '003',
    nombre: 'Jugo de Naranja',
    foto: 'jugo_naranja.png',
    alergenos:[false, false, false],
    precio: 2.00,
    tienda: 'Tienda de Jugos C',
    precioMedida: 10,
    marca: '',
    categoria: 'Jugo',
    oferta: false,
    precioOferta: 0.0,
  );

    List<Producto> productList = [producto1, producto2, producto3];
    var expectedOutput = 0.8;

    // Act
    var result = obtenerProductoMasBarato(productList)?.precio;

    // Assert
    expect(result, expectedOutput);
  });
}
