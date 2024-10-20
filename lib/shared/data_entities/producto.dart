import 'dart:ffi';

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

  // Método para convertir un JSON a un objeto Producto, pasando el prefijo de imagen y el nombre del supermercado como parámetros
  factory Producto.fromJson(Map<String, dynamic> json, {required String imageHost, required String marketName, List<bool>? alergenos}) {
    return Producto(
      id: json['id'] ?? '',
      nombre: json['display_name'] ?? '',
      precio: json['prices']['price'].toDouble(),
      foto: imageHost + (json['image'] ?? ''),
      tienda: marketName,
      alergenos: alergenos ?? [],
    );
  }
}