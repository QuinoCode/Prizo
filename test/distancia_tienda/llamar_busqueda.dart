import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/features/informacion_supermercado/distancia_tienda/application/shop_distance.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  
  ShopDistance s = ShopDistance();
  test('Debe devolver una distancia', () async{
    //Setup
    String query = 'Carrefour';
    //Act
    final s2 = await s.fetchLocationsAPI(query);
    //Assert
    print(s2?["items"][0]["distance"]);
  });

  test('Abre el mapa', () async{
    //Setup
    String query = 'Mercadona';
    //Act
    s.launchMapQuery(query);
    //Assert
  });
}
