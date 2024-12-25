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
  bool oferta;
  double precioOferta;
  final String categoria;
  
  Producto({
    required this.id,
    required this.nombre,
    this.foto = "",
    required this.alergenos,
    required this.precio,
    required this.precioMedida,
    required this.tienda,
    required this.marca, 
    required this.categoria,
    required this.oferta,
    required this.precioOferta,
  });

  @override
  String toString() {
    return 'Producto{id: $id, nombre: $nombre, precio: $precio, imagen: $foto, marca: $marca, glutenFree: ${alergenos[0]}, lactoseFree: ${alergenos[1]}, nutsFree: ${alergenos[2]}}';
  }

  //fromMap is a type of constructor that will create a Producto when provided with a map (which is quite useful since it's what comes from select querys in sqlite(our database model))
  factory Producto.fromMap(Map<String, dynamic> map){
    return Producto(
      id: map['id'],
      nombre: map['nombre'],
      foto: map['foto'],
      alergenos: map['alergenos'],
      precio: map['precio'],
      precioMedida: map['precioMedida'],
      tienda: map['tienda'],
      marca: map['marca'],
      categoria: map['categoria'],
      oferta: map['oferta'] == 1,
      precioOferta: map['precioOferta'],
    );
  }

  //toMap tiene que tener a la izquierda del mapa exactament el mismo nombre que las columnas de la base de datos
  Map<String, dynamic> toMap(){
    return {
      "id": id,
      "nombre": nombre,
      "foto": foto,
      "alergenos": '${alergenos[0] ? 1 : 0}, ${alergenos[1] ? 1 : 0}, ${alergenos[2] ? 1 : 0}',
      "precio": precio,
      "precioMedida": precioMedida,
      "tienda": tienda,
      "marca": marca,
      "categoria": categoria,
      "oferta": oferta ? 1 : 0,
      "precioOferta": precioOferta
    };
  }

  
}
