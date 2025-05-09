import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/shared/application/producto_service.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';

void main() {
  test('debe filtrar productos por alergenos', () {
    // Declaracion de los alérgenos para los productos
    List<bool> producto_con_gluten = [true, false, false];
    List<bool> producto_con_lactosa = [false, true, false];
    List<bool> producto_con_frutos_secos = [false, false, true];
    List<bool> producto_sin_alergenos = [false, false, false];

    // Declaración de productos
    Producto producto1 = Producto(
      id: '003',
      nombre: 'Jugo de Naranja',
      foto: 'jugo_naranja.png',
      precio: 1.00,
      tienda: 'Tienda de Jugos C',
      alergenos: producto_con_gluten,
      precioMedida: 0.5,
      marca: "hacendado", categoria: '',
      oferta: false,
      precioOferta: 0.0,
    );

    Producto producto2 = Producto(
      id: '001',
      nombre: 'Leche',
      foto: 'leche.png',
      precio: 2.00,
      tienda: 'Supermercado A',
      alergenos: producto_con_lactosa,
      precioMedida: 0.5,
      marca: "hacendado", categoria: '',
      oferta: false,
      precioOferta: 0.0,
    );

    Producto producto3 = Producto(
      id: '002',
      nombre: 'Pan de Pepe',
      foto: 'pan.png',
      precio: 3.00,
      tienda: 'Panadería B',
      alergenos: producto_con_frutos_secos,
      precioMedida: 0.5,
      marca: "hacendado", categoria: '',
      oferta: false,
      precioOferta: 0.0,
    );

    Producto producto4 = Producto(
      id: '002',
      nombre: 'Pan de Juan',
      foto: 'pan.png',
      precio: 4.00,
      tienda: 'Panadería B',
      alergenos: producto_sin_alergenos,
      precioMedida: 0.5,
      marca: "hacendado", categoria: '',
      oferta: false,
      precioOferta: 0.0,
    );

    // Declaración de alergenos para las listas de alérgenos
    int GLUTEN = 0;
    int LACTOSA = 1;
    int FRUTOS_SECOS = 2;

    // Arrange
    List<Producto> productos = [
      producto1,
      producto2,
      producto3,
      producto4,
    ];
    List<int> sin_gluten = [GLUTEN];
    List<int> sin_lactosa = [LACTOSA];
    List<int> sin_frutos_secos = [FRUTOS_SECOS];
    List<int> sin_gluten_ni_lactosa = [LACTOSA, GLUTEN];
    List<int> sin_gluten_ni_frutos_secos = [FRUTOS_SECOS, GLUTEN];
    List<int> sin_lactosa_ni_frutos_secos = [FRUTOS_SECOS, LACTOSA];
    List<int> sin_alergenos = [FRUTOS_SECOS, GLUTEN, LACTOSA];

    // Act
    ProductoService productoService = new ProductoService();
    List<Producto> productos_sin_gluten = productoService.sinAlergenos(productos, sin_gluten);
    List<Producto> productos_sin_lactosa = productoService.sinAlergenos(productos, sin_lactosa);
    List<Producto> productos_sin_frutos_secos = productoService.sinAlergenos(productos, sin_frutos_secos);
    List<Producto> productos_sin_gluten_ni_lactosa = productoService.sinAlergenos(productos, sin_gluten_ni_lactosa);
    List<Producto> productos_sin_gluten_ni_frutos_secos = productoService.sinAlergenos(productos, sin_gluten_ni_frutos_secos);
    List<Producto> productos_sin_lactosa_ni_frutos_secos = productoService.sinAlergenos(productos, sin_lactosa_ni_frutos_secos);
    List<Producto> productos_sin_alergenos = productoService.sinAlergenos(productos, sin_alergenos);

    // Assert
    expect(productos_sin_gluten.length, 3);
    expect(productos_sin_gluten[0].precio, 2.00);
    expect(productos_sin_gluten[1].precio, 3.00);
    expect(productos_sin_gluten[2].precio, 4.00);

    expect(productos_sin_lactosa.length, 3);
    expect(productos_sin_lactosa[0].precio, 1.00);
    expect(productos_sin_lactosa[1].precio, 3.00);
    expect(productos_sin_lactosa[2].precio, 4.00);

    expect(productos_sin_frutos_secos.length, 3);
    expect(productos_sin_frutos_secos[0].precio, 1.00);
    expect(productos_sin_frutos_secos[1].precio, 2.00);
    expect(productos_sin_frutos_secos[2].precio, 4.00);

    expect(productos_sin_gluten_ni_lactosa.length, 2);
    expect(productos_sin_gluten_ni_lactosa[0].precio, 3.00);
    expect(productos_sin_gluten_ni_lactosa[1].precio, 4.00);

    expect(productos_sin_gluten_ni_frutos_secos.length, 2);
    expect(productos_sin_gluten_ni_frutos_secos[0].precio, 2.00);
    expect(productos_sin_gluten_ni_frutos_secos[1].precio, 4.00);

    expect(productos_sin_lactosa_ni_frutos_secos.length, 2);
    expect(productos_sin_lactosa_ni_frutos_secos[0].precio, 1.00);
    expect(productos_sin_lactosa_ni_frutos_secos[1].precio, 4.00);

    expect(productos_sin_alergenos.length, 1);
    expect(productos_sin_alergenos[0].precio, 4.00);
  });

  test('debe manejar lista vacía de alergenos sin errores', () {
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
    List<int> lista_alergenos = [];

    // Act
    ProductoService productoService = new ProductoService();
    List<Producto> productosFiltrados = productoService.sinAlergenos(productos, lista_alergenos);

    // Assert
    expect(productosFiltrados[0].precio, 1.50);
    expect(productosFiltrados[1].precio, 0.80);
    expect(productosFiltrados[2].precio, 2.00);
  });

  test('debe manejar lista vacía de productos sin errores', () {
    int GLUTEN = 0;
    int LACTOSA = 1;
    int FRUTOS_SECOS = 2;

    // Arrange
    List<Producto> productos = [];
    List<int> lista_alergenos = [FRUTOS_SECOS, GLUTEN, LACTOSA];

    // Act
    ProductoService productoService = new ProductoService();
    List<Producto> productosFiltrados = productoService.sinAlergenos(productos, lista_alergenos);

    // Assert
    expect(productosFiltrados, isEmpty);
  });

  test('debe manejar lista vacía de productos y lista vacía de alergenos sin errores', () {
    // Arrange
    List<Producto> productos = [];
    List<int> lista_alergenos = [];

    // Act
    ProductoService productoService = new ProductoService();
    List<Producto> productosFiltrados = productoService.sinAlergenos(productos, lista_alergenos);

    // Assert
    expect(productosFiltrados, isEmpty);
  });
}