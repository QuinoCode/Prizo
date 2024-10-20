class MercadonaProduct {
  // Main Product details
  String id;
  String ean;
  String slug;
  String brand;
  int limit;
  bool isWater;
  bool requiresAgeCheck;
  String origin;

  // Photo details
  List<String> photoZooms;
  List<String> photoRegulars;
  List<String> photoThumbnails;
  List<int> photoPerspectives;

  // Supplier details
  List<String> supplierNames;

  // Product description details
  String legalName;
  String description;
  String storageInstructions;

  // Category details
  List<int> categoryIds;
  List<String> categoryNames;
  List<int> categoryLevels;
  List<int> categoryOrders;

  // Pricing and packaging details
  bool isBulk;
  String packaging;
  bool published;
  String shareUrl;
  String thumbnail;
  String displayName;
  int iva;
  bool isNew;
  bool isPack;
  double packSize;
  String unitName;
  double unitSize;
  String bulkPrice;
  String unitPrice;
  bool approxSize;
  String sizeFormat;
  int totalUnits;
  bool unitSelector;
  bool bunchSelector;
  String referencePrice;
  String referenceFormat;

  // Nutrition and allergen details
  String allergens;
  String ingredients;

  MercadonaProduct({
    required this.id,
    required this.ean,
    required this.slug,
    required this.brand,
    required this.limit,
    required this.isWater,
    required this.requiresAgeCheck,
    required this.origin,
    required this.photoZooms,
    required this.photoRegulars,
    required this.photoThumbnails,
    required this.photoPerspectives,
    required this.supplierNames,
    required this.legalName,
    required this.description,
    required this.storageInstructions,
    required this.categoryIds,
    required this.categoryNames,
    required this.categoryLevels,
    required this.categoryOrders,
    required this.isBulk,
    required this.packaging,
    required this.published,
    required this.shareUrl,
    required this.thumbnail,
    required this.displayName,
    required this.iva,
    required this.isNew,
    required this.isPack,
    required this.packSize,
    required this.unitName,
    required this.unitSize,
    required this.bulkPrice,
    required this.unitPrice,
    required this.approxSize,
    required this.sizeFormat,
    required this.totalUnits,
    required this.unitSelector,
    required this.bunchSelector,
    required this.referencePrice,
    required this.referenceFormat,
    required this.allergens,
    required this.ingredients,
  });
}

