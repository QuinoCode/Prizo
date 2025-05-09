class CarrefourProduct {
  // Main Product details
  double active_price;
  double app_price;
  double? average_weight;
  String? brand;
  String catalog_ref_id;
  String? color_rollup;
  String display_name;
  String? document_type;
  String ean13;
  String image_path;
  List<dynamic>? info_tags; //This is where alergens are listed
  double list_price;
  String measure_unit;
  int num_images;
  String price_per_unit_text;
  String product_id;
  String? section;
  int? sell_pack_unit;
  int? stock;
  double? unit_conversion_factor;
  String? url;
  bool? has_offers;

  CarrefourProduct({
    required this.active_price,
    required this.app_price,
    required this.average_weight,
    required this.brand,
    required this.catalog_ref_id,
    required this.color_rollup,
    required this.display_name,
    required this.document_type,
    required this.ean13,
    required this.image_path,
    required this.info_tags,
    required this.list_price,
    required this.measure_unit,
    required this.num_images,
    required this.price_per_unit_text,
    required this.product_id,
    required this.section,
    required this.sell_pack_unit,
    required this.stock,
    required this.unit_conversion_factor,
    required this.url,
    required this.has_offers,
  });

}