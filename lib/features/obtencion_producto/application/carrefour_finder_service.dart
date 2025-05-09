import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prizo/features/obtencion_producto/application/finder_wrapper.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/features/obtencion_producto/domain/response_api_carrefour_data_model.dart';
import 'obtencion_producto_service.dart';

class CarrefourFinderService implements FinderWrapper{
  static int sessionCounter = 0;
  static int httpTrys = 0;
  @override
  final String marketUri = "https://www.carrefour.es/search-api/query/v1/search?query=%q&scope=tablet&lang=es&session=%s&rows=24&start=0&origin=default&f.op=OR";

  @override
  Future<List<Producto>> getProductList(String query) async {
    List<Producto> productsList = [];
    http.Response? response;
    response = await doHttpRequest(query);
    if (response == null) return [];
    var unprocessedItems = getItemsFromHttpReply(response!);
    List<CarrefourProduct> processedItems = convertListOfItemsIntoCarrefourProducts(unprocessedItems);
    productsList = convertCarrefourProductIntoProducto(processedItems);
    return productsList;
  }

  Future<http.Response?> doHttpRequest(String query) async {
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
        httpTrys = 0;
        return response;
      } catch (e) {
          httpTrys++;  
          if (httpTrys < 5 ) {doHttpRequest(query);}
          else {
            print("EXCEPTION WHEN DOING AN HTTP REQUEST: " + e.toString());
            //TODO show error message here
          }
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
          active_price: (item['active_price']).toDouble(),
          app_price: (item['app_price']).toDouble(),
          average_weight: (item['average_weight'] ?? -1.0).toDouble(),
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
          num_images: item['num_images'] ?? 0,
          price_per_unit_text: item['price_per_unit_text'] ?? "",
          product_id: item['product_id'],
          section: item['section'],
          sell_pack_unit: item['sell_pack_unit'],
          stock: item['stock'],
          unit_conversion_factor: (item['unit_conversion_factor'] ?? -1.0).toDouble(),
          url: item['url'],
          has_offers: item['has_offers'] ?? false,
          );
          carrefourProducts.add(placeHolder);
      }
        return carrefourProducts;
  }

  List<Producto> convertCarrefourProductIntoProducto(List<CarrefourProduct> carrefourProducts){
    List<Producto> productos = [];
    for (CarrefourProduct carrefourProduct in carrefourProducts){
      Producto producto = Producto(
        id: carrefourProduct.ean13,
        nombre: ObtencionProductoService.limpiarNombreProducto(carrefourProduct.display_name, carrefourProduct.brand ?? "Marca blanca", "Carrefour"),
        alergenos: extractAlergens(carrefourProduct) ?? [true, true, true],
        precio: carrefourProduct.list_price,
        precioMedida: parsePrecioMedida(carrefourProduct.price_per_unit_text),
        tienda: "Carrefour",
        marca: carrefourProduct.brand ?? "Marca blanca",
        foto: carrefourProduct.image_path,
        categoria: carrefourProduct.display_name.split(' ')[0],
        oferta: carrefourProduct.has_offers ?? false,
        precioOferta: carrefourProduct.active_price,
       );
       productos.add(producto);
    }
    return productos;
  }

  double parsePrecioMedida(String pricePerUnitText){
    if (pricePerUnitText == "") return -1.0;
    String splittedPrice = pricePerUnitText.split(' ')[0];
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
