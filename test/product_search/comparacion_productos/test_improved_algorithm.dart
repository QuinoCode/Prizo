import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/features/comparacion_productos/application/comparacion_producto.dart';
import 'package:prizo/features/product_search/product_search_DIA/application/dia_finder_service.dart';
import 'package:prizo/features/product_search/product_search_carrefour/application/carrefour_finder_service.dart';
import 'package:prizo/features/product_search/product_search_consum/application/consum_finder_service.dart';

void main() async {

  group('algorithm test', () {
    test('Should separate items on two separate lists and bring the one from the same category as the first result of a search in the API' +
       'first and then the rest of the items', () async {

      CarrefourFinderService c4Finder = CarrefourFinderService();
      ConsumFinderService consumFinder = ConsumFinderService();
      DiaFinderService diaFinder = DiaFinderService();
      List<Producto> resultC4 = [];
      List<Producto> resultConsum = [];
      List<Producto> resultDia = [];

      (List<Producto>, List<Producto>) resultC4Tupla = ([],[]);
      (List<Producto>, List<Producto>) resultConsumTupla = ([],[]);
      (List<Producto>, List<Producto>) resultDiaTupla = ([],[]);

      (List<Producto>, List<Producto>) combinedResult = ([],[]);

      String query = "Ketchup";

      resultC4 = await c4Finder.getProductList(query);
      resultConsum = await consumFinder.getProductList(query);
      resultDia = await diaFinder.getProductList(query);

      resultC4Tupla =  ordenaPrioridadCategoria(resultC4);
      resultConsumTupla = ordenaPrioridadCategoria(resultConsum);
      resultDiaTupla = ordenaPrioridadCategoria(resultDia);

      combinedResult = combinaListasSupers([resultC4Tupla, resultConsumTupla, resultDiaTupla]);

      expect(combinedResult, isA<(List<Producto>, List<Producto>)>());
    });
  });

}
