class Producto
{
  final String id;
  final String nombre;
  final String foto;
  final List<String> alergenos;
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
  factory Producto.fromJson(Map<String, dynamic> json, {required String imageHost, required String marketName, List<String>? alergenos}) {
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