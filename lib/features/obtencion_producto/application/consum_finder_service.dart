import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/data_entities/producto.dart';

class ConsumFinderService {
  final String marketUri = "https://tienda.consum.es/api/rest/V1.0/catalog/searcher/products?q=%s&limit=20&showRecommendations=false";
  final String imageHost = "https://www.tienda.consum.es";

  Uri getMarketUri(String query) {
    return Uri.parse(marketUri.replaceFirst('%s', query));
  }

  Future<List<Producto>> fetchProductsFromApi(String query) async {
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
//crear lista de productos
    for (var productJson in productsJsonList) {
      final currProduct = productJson["productData"];
      final marca = currProduct["brand"];
      final priceMap = productJson["priceData"];
      final priceObj = priceMap["prices"];
      final priceVal = priceObj[0]["value"];
      final categoria = currProduct["name"].split(' ')[0];


//crear producto
      final product = Producto(
          id: currProduct["id"] ?? "",
          tienda: "CONSUM",
          marca: marca["name"] ?? "-",
          precio: priceVal["centAmount"],
          precioMedida: priceVal["centUnitAmount"],
          nombre: currProduct["name"],
          foto: productJson["media"][0]["url"],
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
