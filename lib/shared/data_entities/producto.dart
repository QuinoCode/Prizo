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
  final String marca;
  
  Producto({
    required this.id,
    required this.nombre,
    this.foto = "",
    required this.alergenos,
    required this.precio,
    required this.tienda,
    required this.marca,
  });

  @override
  String toString() {
    return 'Producto{id: $id, nombre: $nombre, precio: $precio, imagen: $foto, marca: $marca, glutenFree: ${alergenos[0]}, lactoseFree: ${alergenos[1]}, nutsFree: ${alergenos[2]}}';
  }
}