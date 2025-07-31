class DatabaseProduct {
  // MaprecioOfertaprecioOfertaprecioOfertaprecioOfertaprecioOfertaprecioOfertaprecioOfertain Product details
  String id_product;
  String name;
  String picture_front;
  String picture_back;
  double price;
  double price_measure;
  String brand;
  bool offer;
  double offer_price;
  double offer_price_measure;
  String category;
  String subcategory;
  String supermarket;
  int contains_milk;
  int contains_gluten;
  int contains_nuts;
  int kcalories;
  double fat;
  double saturated_fat;
  double carbohydrates;
  double sugar;
  double proteines;
  double fiber;
  double salt;

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
    required this.category,
    required this.subcategory,
    required this.supermarket,
    required this.contains_milk,
    required this.contains_gluten,
    required this.contains_nuts,
    required this.kcalories,
    required this.fat,
    required this.saturated_fat,
    required this.carbohydrates,
    required this.sugar,
    required this.proteines,
    required this.fiber,
    required this.salt,
  });

}
