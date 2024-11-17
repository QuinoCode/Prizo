import 'package:prizo/features/pantalla_producto/application/pantalla_producto_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debe devolver un string con las dos palabras mas relevantes', () async {
    String nombreDia = "Plátano bio bolsa 1 Kg aprox.";
    String nombreCarrefour = "Lasaña boloñesa Carrefour el Mercado 350 g";
    String nombreConsum = "Queso Cheddar en Lonchas 200 Gr";

    print(PantallaProductoService.limpiarNombreProducto(nombreDia)); // Salida: "pan molde"
    print(PantallaProductoService.limpiarNombreProducto(nombreCarrefour)); // Salida: "pan pasas"
    print(PantallaProductoService.limpiarNombreProducto(nombreConsum)); // Salida: "yogur griego"
  });
}