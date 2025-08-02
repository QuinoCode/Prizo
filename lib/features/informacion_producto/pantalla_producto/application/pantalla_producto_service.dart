import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/features/product_search/product_search_consum/application/consum_finder_service.dart';
import 'package:prizo/features/product_search/product_search_DIA/application/dia_finder_service.dart';
import 'package:prizo/features/product_search/comparacion_productos/application/comparacion_producto.dart';
import 'package:prizo/features/product_search/product_search_carrefour/application/carrefour_finder_service.dart';
import 'package:prizo/features/product_search/product_search_mercadona/application/mercadona_finder_service.dart';
import 'package:flutter/material.dart';


class PantallaProductoService {
  final ConsumFinderService consumService = ConsumFinderService();
  final DiaFinderService diaService = DiaFinderService();
  final CarrefourFinderService carrefourService = CarrefourFinderService();
  final MercadonaFinderService mercadonaService = MercadonaFinderService();

  Future<List<Producto>> obtenerProductosSimilares(String query, Producto productoActual) async {
    try {
      final consumProductsFuture = consumService.getProductList(query);
      final diaProductsFuture = diaService.getProductList(query);
      final carrefourProductsFuture = carrefourService.getProductList(query);
      final mercadonaProductsFuture = mercadonaService.getProductList(query);
      final results = await Future.wait([consumProductsFuture, diaProductsFuture, carrefourProductsFuture, mercadonaProductsFuture]);
      List<Producto> listaCombinada = results[0] + results[1] + results[2] + results[3];
      listaCombinada.removeWhere((producto) => producto.id == productoActual.id);
      ordenarProductosPorPrecio(listaCombinada);
      return listaCombinada;
    } catch (e) {
      print("Error al buscar productos: $e");
      return [];
    }
  }

  static String limpiarNombreProducto(String nombre) {
    // Lista de palabras comunes a eliminar
    List<String> stopwords = [
      "de", "con", "y", "en", "el", "la", "al", "los", "las", "ud", "g", "molino", "kg", "pack", "sabor", "paquete", "bolsa",
      "carrefour", "dia", "consum", "caja", "lata", "botella", "envase", "frasco", "sobre"
    ];

    // Normaliza el texto
    String textoLimpio = nombre
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zñáéíóúü\s]'), '');

    // Divide el texto en palabras y filtra las stopwords
    List<String> palabrasFiltradas = textoLimpio.split(' ').where((palabra) {
      return !stopwords.contains(palabra) && palabra.length > 1;
    }).toList();

    if (palabrasFiltradas.length > 2) {
      palabrasFiltradas = palabrasFiltradas.sublist(0, 2);
    } else if (palabrasFiltradas.length <= 2) {
      return palabrasFiltradas[0];
    }

    return palabrasFiltradas.join(' ');
  }

  Image obtenerLogoSupermercado(Producto producto) {
    switch (producto.tienda.toLowerCase()) {
      case 'dia':
        return Image.asset('assets/images/logo_dia.png');
      case 'consum':
        return Image.asset('assets/images/logo_consum.png');
      case 'carrefour':
        return Image.asset('assets/images/logo_carrefour.png');
      case 'mercadona':
        return Image.asset('assets/images/logo_mercadona.png');
      default:
        return Image.asset('assets/images/default.png');
    }
  }
}
