class Producto
{
  final String id;
  final String nombre;
  final String foto;
  final List<bool> alergenos;
  /*
  Explicación campo alérgenos
  -----------------------------
  Consistirá en una lista de 3 booleanos con las posiciones establecidas de la siguiente manera
  - Posición 0: booleano para el GLUTEN
  - Posición 1: booleano para la LACTOSA
  - Posición 2: booleano para los FRUTOS SECOS
  En caso de ser 0 no contendrá este alérgeno el producto, en caso de ser uno si lo contendrá
  */
  final double precio;
  final String tienda;
  
  Producto({
    required this.id,
    required this.nombre,
    required this.foto,
    required this.alergenos,
    required this.precio,
    required this.tienda,
  });

  // Método para convertir un JSON a un objeto Producto
  factory Producto.fromJson(Map<String, dynamic> json, {required String imageHost, required String marketName, required Map<String, dynamic> facets}) {
    // Obtener el estado de los alérgenos
    bool glutenFree = _getAllergenStatus(facets, 'gluten_free');
    bool lactoseFree = _getAllergenStatus(facets, 'lactose_free');
    bool nutsFree = _getAllergenStatus(facets, 'nuts_free');

    return Producto(
      id: json['object_id'] ?? '', // Utiliza el campo adecuado del JSON
      nombre: json['display_name'] ?? '',
      precio: json['prices']['price'].toDouble(),
      foto: imageHost + (json['image'] ?? ''),
      tienda: marketName,
      alergenos: [glutenFree, lactoseFree, nutsFree], // Asignación de alérgenos
    );
  }

  // Método para obtener el estado de un alérgeno
  static bool _getAllergenStatus(Map<String, dynamic> facets, String allergenKey) {
    // Busca el facet correspondiente al alérgeno
    final allergenFacet = facets[allergenKey];

    if (allergenFacet != null) {
      // Busca el filtro habilitado
      final filter = allergenFacet['filters']
          .firstWhere((filter) => filter['enabled'] == true, orElse: () => null);

      if (filter != null) {
        return filter['title'] == 'SI'; // Devuelve true si el producto es libre de alérgenos
      }
    }
    return false; // Retorna false si no se encuentra el estado
  }
}