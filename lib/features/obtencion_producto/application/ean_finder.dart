import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prizo/features/obtencion_producto/application/carrefour_finder_service.dart';
import 'package:prizo/features/obtencion_producto/application/consum_finder_service.dart';
import 'package:prizo/features/obtencion_producto/application/dia_finder_service.dart';
import 'package:prizo/features/obtencion_producto/application/finder_wrapper.dart';
import 'package:prizo/shared/data_entities/producto.dart';

class EanFinder {
  final String marketUri = "https://world.openfoodfacts.net/api/v2/product/%q";

  // Devuelve una lista con cada posición de la misma siendo el equivalente al producto buscado por EAN en dicho supermercado
  // 0. Carrefour
  // 1. Dia
  // 2. Consum
  Future<List<Producto?>> getProductList(String query) async {
    http.Response? response;
    while (response == null) response = await doHttpRequest(query);
    var unprocessedItems = getItemFromHttpReply(response);
    Map<String,dynamic> productSearch = convertItemToProductSearch(unprocessedItems);
    Producto? productCarrefour = await find_ean_in_finders(productSearch, "carrefour");
    Producto? productoDia = await find_ean_in_finders(productSearch, "dia");
    Producto? productoConsum = await find_ean_in_finders(productSearch, "consum");
    return [productCarrefour, productoDia, productoConsum];
  }

  Future<http.Response?> doHttpRequest(String query) async{
      try {
        http.Response response;
        String url;
        url = putQueryInUri(marketUri, query);
        response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
            "Keep-Alive": "timeout=5, max=2"
          },
          );
        while (response.statusCode != 200){response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
            "Keep-Alive": "timeout=5, max=2"
          },
          );
        }
        return response;
      } catch (e) {
          print("EXCEPTION WHEN DOING AN HTTP REQUEST: " + e.toString());
      }
      return null;
  }

  Map<String,dynamic> getItemFromHttpReply(http.Response response){
      Map<String, dynamic> decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      Map<String, dynamic> item = decodedResponse['product'];
      return item;
  }
  Future<Producto?> find_ean_in_finders(Map<String, dynamic> productSearch, String finderType) async {
    FinderWrapper finder= FinderWrapper(finderType);
    List<Producto> products = [];
    if (finder is ConsumFinderService) {
      products = await finder.getProductList(productSearch["marca"]);
      return find_productInList(productSearch, products);
    }
    if (finder is CarrefourFinderService) {
      products = await finder.getProductList(productSearch["nombre"]);
      return find_productInList(productSearch, products);
      }
    if (finder is DiaFinderService){
      products = await finder.getProductList(productSearch["ean"]);
      return products[0];
      }
    return null;
  }

  Producto? find_productInList(Map<String, dynamic> productSearch, List<Producto> products) {
    for (Producto product in products) {
      if (productSearch["ean"] == product.id){ return product; }
    }
    return null;
  }

  Map<String, dynamic> convertItemToProductSearch(Map<String, dynamic> item){
    Map<String, dynamic> productSearch = {
    "ean": item["_id"],
    "nombre":  item["product_name_es"],
    "marca": item["brands"] ?? ""
    };
    return productSearch;
  }

  String putQueryInUri(String url, String query) {
    return url.replaceFirst("%q", query);
  }

}
