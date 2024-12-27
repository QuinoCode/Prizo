import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/features/comparacion_productos/application/comparacion_producto.dart';  // Import the file with the function
import 'package:prizo/shared/data_entities/models/producto.dart';

void main() {
  test('debe ordenar productos por precio de menor a mayor', () {
    Producto producto1 = Producto(
      id: '001',
      nombre: 'Leche',
      foto: 'leche.png',
      precio: 1.50,
      tienda: 'Supermercado A',
      alergenos: [false, true, false],
      precioMedida: 0.5,
      marca: "hacendado", categoria: '',
      oferta: false,
      precioOferta: 0.0,
    );

    Producto producto2 = Producto(
      id: '002',
      nombre: 'Pan',
      foto: 'pan.png',
      precio: 0.80,
      tienda: 'Panadería B',
      alergenos: [false, true, false],
      precioMedida: 0.5,
      marca: "hacendado", categoria: '',
      oferta: false,
      precioOferta: 0.0,
    );

    Producto producto3 = Producto(
      id: '003',
      nombre: 'Jugo de Naranja',
      foto: 'jugo_naranja.png',
      precio: 2.00,
      tienda: 'Tienda de Jugos C',
      alergenos: [false, true, false],
      precioMedida: 0.5,
      marca: "hacendado", categoria: '',
      oferta: false,
      precioOferta: 0.0,
    );

    // Arrange
    List<Producto> productos = [
      producto1,
      producto2,
      producto3,
    ];

    // Act
    ordenarProductosPorPrecio(productos);

    // Assert
    expect(productos[0].precio, 0.80);
    expect(productos[1].precio, 1.50);
    expect(productos[2].precio, 2.00);
  });

  test('debe manejar lista vacía sin errores', () {
    // Arrange
    List<Producto> productos = [];

    // Act
    ordenarProductosPorPrecio(productos);

    // Assert
    expect(productos, isEmpty);
  });
}