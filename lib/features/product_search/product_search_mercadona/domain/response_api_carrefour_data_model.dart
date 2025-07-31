class DatabaseProduct {
  // Main Product details
  int id_product;
  String name;
  String? picture_front;
  String? picture_back;
  double price;
  String? price_measure;
  String brand;
  bool offer;
  double offer_price;
  String offer_price_measure;

  DatabaseProduct({
    required this.id_product,
    required this.name,
    required this.picture_front,
    required this.picture_back,
    required this.price,
    required this.price_measure,
    required this.brand,
    required this.offer,
    required this.offer_price,
    required this.offer_price_measure,
  });

}
