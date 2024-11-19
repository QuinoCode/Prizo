import 'package:prizo/features/pantalla_producto/application/pantalla_producto_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debe devolver un string con las dos palabras mas relevantes', () async {
    String nombreDia = "Almendras al natural sin piel Naturmundo de dia bolsa 200 g";
    String nombreCarrefour = "Almendras crudas Carrefour 200g.";
    String nombreConsum = "Almendra Repelada Cruda";

    String nombreDiaLimpio = PantallaProductoService.limpiarNombreProducto(nombreDia);
    String nombreCarrefourLimpio = PantallaProductoService.limpiarNombreProducto(nombreCarrefour);
    String nombreConsumLimpio = PantallaProductoService.limpiarNombreProducto(nombreConsum);

    print(nombreDiaLimpio);
    print(nombreCarrefourLimpio);
    print(nombreConsumLimpio);

    expect(nombreDiaLimpio, equals("almendras sin"));
    expect(nombreCarrefourLimpio, equals("almendras crudas"));
    expect(nombreConsumLimpio, equals("almendra repelada"));
  });
}