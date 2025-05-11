import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prizo/features/product_search/obtencion_producto/application/finder_wrapper.dart';
import 'dart:io';
import '../../../../shared/data_entities/models/producto.dart';
import '../../obtencion_producto/application/obtencion_producto_service.dart';

class ConsumFinderService implements FinderWrapper{
  @override
  final String marketUri = "https://tienda.consum.es/api/rest/V1.0/catalog/searcher/products?q=%s&limit=20&showRecommendations=false";
  final String imageHost = "https://www.tienda.consum.es";

  Uri getMarketUri(String query) {
    return Uri.parse(marketUri.replaceFirst('%s', query));
  }

  @override
  Future<List<Producto>> getProductList(String query) async {
    HttpOverrides.global = MyHttpOverrides();
    try {
      final url = getMarketUri(query);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body);
        final productsJsonMap = jsonResp["catalog"];
        final productsJsonList = productsJsonMap["products"];
        return _parseProductList(productsJsonList);
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  Future<List<Producto>> _parseProductList(List productsJsonList) async {
    final List<Producto> productList = [];
    /*crear lista de productos */
    for (var productJson in productsJsonList) {
      final currProduct = productJson["productData"];
      final marca = currProduct["brand"];
      final priceMap = productJson["priceData"];
      final priceObj = priceMap["prices"];
      final priceVal = priceObj[0]["value"];
      final categoria = productJson["categories"][0]["name"];
      /*crear producto */
      final product = Producto(
          id: productJson["ean"] ?? "",
          tienda: "Consum",
          marca: marca["name"] ?? "-",
          precio: priceVal["centAmount"],
          precioMedida: priceVal["centUnitAmount"],
          nombre: ObtencionProductoService.limpiarNombreProducto(currProduct["name"], marca["name"] ?? "-", "Consum"),
          foto: productJson["media"].length > 0 ? productJson["media"][0]["url"] : 'assets/images/placeholder.jpg',
          alergenos: [false, false, false],
          categoria: categoria,
          oferta: priceObj.length > 1,
          precioOferta: priceObj.length > 1 ? priceObj[1]["value"]["centAmount"] : priceVal["centAmount"],
      );

      productList.add(product);
    }
    return productList;
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
