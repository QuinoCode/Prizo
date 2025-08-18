import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prizo/features/product_search/application/finder_wrapper.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/features/product_search/product_search_mercadona/domain/database_product_model.dart';
import 'package:prizo/features/product_search/application/obtencion_producto_service.dart';

class MercadonaFinderService implements FinderWrapper{
  static int sessionCounter = 0;
  static int httpTrys = 0;
  @override
  final String marketUri = "http://192.168.1.206:5000/search?name=%q";

  @override
  Future<List<Producto>> getProductList(String query) async {
    List<Producto> productsList = [];
    List<DatabaseProduct> databaseProductsList = [];
    http.Response? response;
    response = await doHttpRequest(query);
    if (response == null) return [];
    var unprocessedItems = getItemsFromHttpReply(response);
    databaseProductsList = convert_unprocessed_items_into_databaseProducts(unprocessedItems);
    productsList = convert_database_product_into_app_product(databaseProductsList);
    return productsList;
  }

  Future<http.Response?> doHttpRequest(String query) async {
      try {
        http.Response response;
        String url;
        url = putQueryInMarketUri(marketUri, query);
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
        httpTrys = 0;
        return response;
      } catch (e) {
          httpTrys++;  
          if (httpTrys < 5 ) {doHttpRequest(query);}
          else {
            print("EXCEPTION WHEN DOING AN HTTP REQUEST: " + e.toString());
          }
      }
      return null;
  }

   getItemsFromHttpReply(http.Response response){
        Map<String, dynamic> decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> databaseProducts = decodedResponse["results"];
        return databaseProducts;

  }
  List<DatabaseProduct> convert_unprocessed_items_into_databaseProducts(List<dynamic> database_products){
    List<DatabaseProduct> productos = [];
    for (Map<String, dynamic> database_product in database_products){
      DatabaseProduct producto = DatabaseProduct(
        id_product: database_product["id_product"].toString(),
        name: ObtencionProductoService.limpiarNombreProducto(database_product["name"], database_product["brand"] ?? "Hacendado", "Mercadona"),
        price: parsePrecioMedida(database_product["price"]),
        price_measure: parsePrecioMedida(database_product["price_measure"]),
        supermarket: database_product["supermarket"],
        brand: database_product["brand"] ?? "Hacendado",
        picture_front: database_product["picture_front"],
        picture_back: database_product["picture_back"],
        category: database_product["category"],
        subcategory: database_product["subcategory"],
        offer: database_product["offer"] == 1,
        offer_price: ((database_product["offer_price"] is String) ? parsePrecioMedida(database_product["offer_price"]) : database_product["offer_price"]) ?? 1.00,
        offer_price_measure: 1.00,//database_product["offer_price_measure"],
        contains_gluten: database_product["contains_gluten"],
        contains_milk: database_product["contains_milk"],
        contains_nuts: database_product["contains_nuts"],
        kcalories: (database_product["kcalories"] as num).round(),
        fat: database_product["fat"],
        saturated_fat: database_product["saturated_fat"],
        carbohydrates: database_product["carbohydrates"],
        sugar: database_product["sugar"],
        proteines: database_product["proteines"],
        fiber: database_product["fiber"],
        salt: database_product["salt"],
       );
       productos.add(producto);
    }
    return productos;
  }
  List<Producto> convert_database_product_into_app_product(List<DatabaseProduct> database_products){
    List<Producto> productos = [];
    for (DatabaseProduct database_product in database_products){
      Producto producto = Producto(
        id: database_product.id_product,
        nombre: ObtencionProductoService.limpiarNombreProducto(database_product.name, database_product.brand ?? "Hacendado", "Mercadona"),
        alergenos: extractAlergens(database_product) ?? [true, true, true],
        precio: database_product.price,
        precioMedida: database_product.price_measure,
        tienda: database_product.supermarket,
        marca: database_product.brand ?? "Hacendado",
        foto: database_product.picture_front,
        picture_back: database_product.picture_back,
        categoria: database_product.category,
        oferta: database_product.offer ?? false,
        precioOferta: database_product.offer_price,
       );
       productos.add(producto);
    }
    return productos;
  }

  double parsePrecioMedida(String pricePerUnitText){
    if (pricePerUnitText == "") return -1.0;
    String splittedPrice = pricePerUnitText.split(' ')[0];
    String doubleFormattedPrice = splittedPrice.replaceAll(",", ".");
    String withoutEuroCharacter = doubleFormattedPrice.replaceAll("€", "");
    print("Double to be parsed: {" + withoutEuroCharacter + "}");
    //TODO: Remove la guarrada
    if (withoutEuroCharacter == "") return 1.00;
    return double.parse(withoutEuroCharacter);
  }

  List<bool>? extractAlergens(DatabaseProduct database_product){
    List<bool> result = [true, true, true];
    if (database_product.contains_gluten == 0) result[0] = false;
    if (database_product.contains_milk == 0) result[1] = false;
    if (database_product.contains_nuts == 0) result[2] = false;
    return result;
  }

  String putQueryInMarketUri(String url, String query) {
    return url.replaceFirst("%q", query);
  }
}
