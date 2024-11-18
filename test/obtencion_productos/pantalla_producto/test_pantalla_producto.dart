import 'package:prizo/features/pantalla_producto/application/pantalla_producto_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debe devolver un string con las dos palabras mas relevantes', () async {
    String nombreDia = "Almendras al natural sin piel Naturmundo de dia bolsa 200 g";
    String nombreCarrefour = "Almendras crudas Carrefour 200g.";
    String nombreConsum = "Almendra Repelada Cruda";

    print(PantallaProductoService.limpiarNombreProducto(nombreDia));
    print(PantallaProductoService.limpiarNombreProducto(nombreCarrefour));
    print(PantallaProductoService.limpiarNombreProducto(nombreConsum));
  });
}