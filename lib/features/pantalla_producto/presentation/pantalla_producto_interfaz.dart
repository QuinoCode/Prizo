import 'package:flutter/material.dart';
import '../../../shared/data_entities/models/producto.dart';
import '../../lista_compra/application/lista_compra_service.dart';
import '../../lista_favoritos/application/lista_favoritos_service.dart';
import '../../../shared/data_entities/models/lista_compra.dart';
import '../../../shared/data_entities/models/lista_favoritos.dart';
import '../../pantalla_producto/application/pantalla_producto_service.dart';
import '../../distancia_tienda/shop_distance.dart';

class DetallesProducto extends StatelessWidget {
  final Producto producto;
  final ListaCompraService listaCompraService = ListaCompraService();
  final ListaFavoritosService listaFavoritosService = ListaFavoritosService();
  final ListaCompra listaCompra;
  final ListaFavoritos listaFavoritos;
  final PantallaProductoService pantallaProductoService = PantallaProductoService();
  final ShopDistance shopDistance = ShopDistance();

  DetallesProducto({
    Key? key,
    required this.producto,
    required this.listaCompra,
    required this.listaFavoritos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = producto.foto;
    final precioMedida = producto.precioMedida > 0 ? '${producto.precioMedida.toStringAsFixed(2)}€/kg' : '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: null, // Eliminar título del AppBar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del supermercado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        producto.tienda,
                        style: const TextStyle(fontSize: 20, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // Botón de favoritos
                      GestureDetector(
                        onTap: () async {
                          try {
                            if (listaFavoritosService.productoEnFavoritos(listaFavoritos, producto)) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Producto ya en favoritos'),
                                    content: Text('${producto.nombre} ya se encuentra en tu lista de favoritos.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Ok'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              listaFavoritosService.annadirProducto(listaFavoritos, producto);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${producto.nombre} añadido a favoritos')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al añadir a favoritos')),
                            );
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF95B3FF),
                          ),
                          child: const Icon(Icons.favorite_border, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Botón de distancia
                      GestureDetector(
                        onTap: () async {
                          try {
                            shopDistance.launchMapQuery(producto.tienda);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al mostrar el mapa')),
                            );
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF95B3FF),
                          ),
                          child: const Icon(Icons.place_outlined, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Imagen del producto
              Center(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 100);
                  },
                )
                    : const Icon(Icons.image_not_supported, size: 100),
              ),
              const SizedBox(height: 16),

              // Nombre del producto
              Text(
                producto.nombre,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Marca
              Text(
                producto.marca,
                style: const TextStyle(fontSize: 17, color: Colors.black),
              ),
              const SizedBox(height: 8),

              // Precio y botón de añadir al carrito
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${producto.precio.toStringAsFixed(2)}€',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        precioMedida,
                        style: const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                  // Botón añadir al carrito
                  GestureDetector(
                    onTap: () async {
                      try {
                        listaCompraService.annadirProducto(listaCompra, producto);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${producto.nombre} añadido a la lista de compra')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error al añadir a la lista de compra')),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFF95B3FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.add_shopping_cart, color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // Barra azul de separación
              Container(
                height: 2,
                color: Color(0xFF95B3FF),
              ),
              const SizedBox(height: 50),

              // Productos relacionados
              Text(
                'Productos relacionados',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),

              FutureBuilder<List<Producto>>(
                future: pantallaProductoService.obtenerProductosSimilares(
                    PantallaProductoService.limpiarNombreProducto(producto.nombre), producto),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar productos relacionados.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay productos relacionados.'));
                  } else {
                    List<Producto> productosRelacionados = snapshot.data!;
                    return SizedBox(
                      height: 200, // Altura ajustada para espacio adicional
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: productosRelacionados.length,
                        itemBuilder: (context, index) {
                          Producto productoRelacionado = productosRelacionados[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetallesProducto(
                                    producto: productoRelacionado,
                                    listaCompra: listaCompra,
                                    listaFavoritos: listaFavoritos,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Alinear a la izquierda
                                children: [
                                  // Nombre del supermercado centrado a la izquierda
                                  SizedBox(
                                    width: 95,
                                    child: Text(
                                      productoRelacionado.tienda,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.left, // Centrado a la izquierda
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Imagen del producto
                                  Image.network(
                                    productoRelacionado.foto,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image, size: 60);
                                    },
                                  ),
                                  const SizedBox(height: 8),

                                  // Nombre del producto
                                  SizedBox(
                                    width: 95,
                                    child: Text(
                                      productoRelacionado.nombre,
                                      style: const TextStyle(fontSize: 10),
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Precio del producto
                                  Text(
                                    '${productoRelacionado.precio.toStringAsFixed(2)}€',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
