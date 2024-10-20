import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/data_entities/producto.dart';

class DiaFinderService {
  final String marketUri = "https://www.dia.es/api/v1/search-back/search/reduced?q=%s&page=1";
  final String imageHost = "https://www.dia.es";

  Future<List<Producto>> fetchProductsFromApi(String query) async {
    final url = Uri.parse(marketUri.replaceFirst('%s', query));

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return _parseProductList(jsonData);
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  List<Producto> _parseProductList(Map<String, dynamic> json) {
    final List<Producto> productList = [];
    final productsJsonList = json['search_items'] as List<dynamic>;

    final facets = json['facets'];

    for (final productJson in productsJsonList) {
      final productObj = Producto.fromJson(
        productJson,
        imageHost: imageHost,
        marketName: "DIA",
        facets: facets,
      );
      productList.add(productObj);
    }

    return productList;
  }
}

