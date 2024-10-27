
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../shared/data_entities/producto.dart';
import '../domain/response_api_mercadona_data_model.dart';

class MercadonaFinderService {
  final String marketUri = "https://tienda.mercadona.es/api/v1_1/products/%s";
  //final String imageHost = "https://www.dia.es";

  String getMarketUri(String query) {
    return marketUri.replaceFirst("%s", query);
  }
  Future<MercadonaProduct?> doHttpRequest(String query) async{
      MercadonaProduct? mercadonaProduct;
      try {
        final url = getMarketUri(query);
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final mercadonaProduct = json.decode(response.body);
          print(mercadonaProduct);
        }
      } catch (e) {
          print(e);
        return null;
      }
      return  mercadonaProduct;
  }

  Future<List<Producto>> getProductList(String query) async {
    final List<Producto> productList = [];

        final MercadonaProduct? replyFromAPI = await doHttpRequest(query);
        if (replyFromAPI == null) {return [];}
        //final List productsJsonList = jsonResponse["search_items"];
        //final List facets = jsonResponse["facets"];

        // Variables para almacenar los valores de gluten, lactosa y frutos secos
        bool glutenFree = false;
        bool lactoseFree = false;
        bool nutsFree = false;

        // Extraer información de los campos facets (alergenos)
        /*
        for (var facet in facets) {
          if (facet["field"] == "gluten_free") {
            glutenFree = facet["filters"][0]["title"].toLowerCase() == "si";
          } else if (facet["field"] == "lactose_free") {
            lactoseFree = facet["filters"][0]["title"].toLowerCase() == "si";
          } else if (facet["field"] == "nuts_free") {
            nutsFree = facet["filters"][0]["title"].toLowerCase() == "si";
          }
        }

        // Procesar la lista de productos
        for (var productJson in productsJsonList) {
          final pricesObj = productJson["prices"];
          final product = Producto(
            id: productJson["object_id"] ?? "",
            tienda: "DIA",
            marca: productJson["brand"] ?? "-",
            precio: pricesObj["strikethrough_price"].toDouble(),
            nombre: productJson["display_name"],
            foto: productJson["image"].isNotEmpty
                ? imageHost + productJson["image"]
                : "",
            alergenos: [glutenFree, lactoseFree, nutsFree],
          );
          if (pricesObj["is_promo_price"] == true) {
            product.oferta = true;
          }
          product.precioOferta = pricesObj["price"].toDouble();
          productList.add(product);
        }
      } else {
        print("Error fetching products: ${response.statusCode}");
      }

        */
    return productList;
  }
}


