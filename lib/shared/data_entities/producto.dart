class Producto
{
  final String id;
  final String nombre;
  final String foto;
  final List<bool> alergenos;
  //
  //Explicación campo alérgenos
  //-----------------------------
  //Consistirá en una lista de 3 booleanos con las posiciones establecidas de la siguiente manera
  //- Posición 0: booleano para el GLUTEN
  //- Posición 1: booleano para la LACTOSA
  //- Posición 2: booleano para los FRUTOS SECOS
  //
  double precio;
  double precioMedida;
  final String tienda;
  final String marca;
  bool oferta = false;
  double precioOferta = 0.0;
  
  Producto({
    required this.id,
    required this.nombre,
    this.foto = "",
    required this.alergenos,
    required this.precio,
    required this.precioMedida,
    required this.tienda,
    required this.marca, 
  });

  @override
  String toString() {
    return 'Producto{id: $id, nombre: $nombre, precio: $precio, imagen: $foto, marca: $marca, glutenFree: ${alergenos[0]}, lactoseFree: ${alergenos[1]}, nutsFree: ${alergenos[2]}}';
  }

  bool equals(Producto otro) {
    return id == otro.id &&
        nombre == otro.nombre &&
        (foto == null ? otro.foto == null : (otro.foto == null ? false : foto == otro.foto)) &&
        _listasIguales(alergenos, otro.alergenos) &&
        precio == otro.precio &&
        precioMedida == otro.precioMedida &&
        tienda == otro.tienda &&
        marca == otro.marca &&
        oferta == otro.oferta &&
        precioOferta == otro.precioOferta;
  }

  bool _listasIguales(List<bool> lista1, List<bool> lista2) {
    if (lista1.length != lista2.length) return false;
    for (int i = 0; i < lista1.length; i++) {
      if (lista1[i] != lista2[i]) return false;
    }
    return true;
  }
}
