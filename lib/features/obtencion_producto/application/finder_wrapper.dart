import 'package:prizo/features/obtencion_producto/application/carrefour_finder_service.dart';
import 'package:prizo/features/obtencion_producto/application/consum_finder_service.dart';
import 'package:prizo/features/obtencion_producto/application/dia_finder_service.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';

abstract class FinderWrapper {
  final String marketUri = "https://world.openfoodfacts.net/api/v2/product/%q";

  factory FinderWrapper (String type){

    switch (type) {
      case "carrefour":
        return CarrefourFinderService();
      case "dia":
        return DiaFinderService();
      case "consum":
        return ConsumFinderService();
      default:
        throw ArgumentError("Finder type not declared / wrong: $type");
    }
  }
  Future<List<Producto>> getProductList(String query);
}
