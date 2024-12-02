import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/features/distancia_tienda/shop_distance.dart';

void main() {
  test('Debe devolver una distancia', (){

    //Setup
    ShopDistance s = ShopDistance();
    //Act
    s.fetchLocationsAPI('consum');
    //Assert
  });

}