import 'package:flutter_test/flutter_test.dart';
import 'package:prizo/features/distancia_tienda/shop_distance.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Debe devolver una distancia', () async{

    //Setup
    ShopDistance s = ShopDistance();
    //Act
    final s2 = await s.getCurrentPosition();
    print(s2);
    //Assert
  });

}