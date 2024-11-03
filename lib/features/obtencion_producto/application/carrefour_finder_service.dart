import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prizo/shared/data_entities/producto.dart';
import 'package:prizo/features/obtencion_producto/domain/response_api_carrefour_data_model.dart';

class CarrefourFinderService {
  static int sessionCounter = 0;
  final String marketUri = "https://www.carrefour.es/search-api/query/v1/search?query=%q&scope=tablet&lang=es&session=%s&rows=24&start=0&origin=default&f.op=OR";

  Future<List<Producto>> getProductList(String query) async {
    List<Producto> productsList = [];
    http.Response? response;
    while (response == null) response = await doHttpRequest(query);
    var unprocessedItems = getItemsFromHttpReply(response);
    List<CarrefourProduct> processedItems = convertListOfItemsIntoCarrefourProducts(unprocessedItems);
    productsList = convertCarrefourProductIntoProducto(processedItems);
    return productsList;
  }

  Future<http.Response?> doHttpRequest(String query) async{
      try {
        http.Response response;
        String url;
        url = putQueryInMarketUri(marketUri, query);
        url = putSessionInMarketUri(url, sessionCounter.toString());
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

   getItemsFromHttpReply(http.Response response){
        Map<String, dynamic> decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> items = decodedResponse['content']['docs'];
        return items;

  }
   convertListOfItemsIntoCarrefourProducts(List items){
      List<CarrefourProduct> carrefourProducts = [];
      for (var item in items){ 
        CarrefourProduct placeHolder = CarrefourProduct(
          active_price: item['active_price'],
          app_price: item['app_price'],
          average_weight: item['average_weight'] ?? -1,
          brand: item['brand'] ?? "",
          catalog_ref_id: item['catalog_ref_id'],
          color_rollup: item['color_rollup'],
          display_name: item['display_name'],
          document_type: item['document_type'],
          ean13: item['ean13'],
          image_path: item['image_path'],
          info_tags: item['info_tags'],
          list_price: (item['list_price'] ?? -1.0).toDouble(), 
          measure_unit: item['measure_unit'] ?? "",
          num_images: item['num_images'],
          price_per_unit_text: item['price_per_unit_text'] ?? "",
          product_id: item['product_id'],
          section: item['section'],
          sell_pack_unit: item['sell_pack_unit'],
          stock: item['stock'],
          unit_conversion_factor: (item['unit_conversion_factor'] ?? -1.0).toDouble(),
          url: item['url'],
          );
          carrefourProducts.add(placeHolder);
      }
        return carrefourProducts;
  }

  List<Producto> convertCarrefourProductIntoProducto(List<CarrefourProduct> carrefourProducts){
    List<Producto> productos = [];
    for (CarrefourProduct carrefourProduct in carrefourProducts){
      Producto producto = Producto(
        id: carrefourProduct.ean13 + "C4",
        nombre: carrefourProduct.display_name,
        alergenos: extractAlergens(carrefourProduct) ?? [true, true, true],
        precio: carrefourProduct.active_price,
        precioMedida: parsePrecioMedida(carrefourProduct.price_per_unit_text),
        tienda: "Carrefour",
        marca: carrefourProduct.brand ?? "Marca blanca",
        foto: carrefourProduct.image_path,
       );
       productos.add(producto);
    }
    return productos;
  }

  double parsePrecioMedida(String price_per_unit_text){
    if (price_per_unit_text == "") return -1.0;
    String splittedPrice = price_per_unit_text.split(' ')[0];
    String doubleFormattedPrice = splittedPrice.replaceAll(",", ".");
    return double.parse(doubleFormattedPrice);
  }

  List<bool>? extractAlergens(CarrefourProduct carrefourProduct){
    List<bool> result = [true, true, true];
    if (carrefourProduct.info_tags == null) return null;
    for (var tag in carrefourProduct.info_tags!){
      if (tag['message'].contains("gluten")) {result[0] = false; continue;}
      if (tag['message'].contains("lactosa")) {result[1] = false; continue;}
      if (tag['message'].contains("secos")) result[2] = false;
    }
    return result;
  }

  String putQueryInMarketUri(String url, String query) {
    return url.replaceFirst("%q", query);
  }

  String putSessionInMarketUri(String url, String session) {
    sessionCounter++;
    return url.replaceFirst("%s", session);
  }
}

