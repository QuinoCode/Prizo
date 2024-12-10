import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/features/distancia_tienda/shop_distance.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Debe devolver una distancia', () async{

    //Setup
    ShopDistance s = ShopDistance();
    String query = 'Carrefour';
    //Act
    final s2 = await s.fetchLocationsAPI(query);
    //Assert
    print(s2);
  });

}