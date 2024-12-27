import 'package:flutter/material.dart';
import '../../../shared/data_entities/models/producto.dart';
import '../../lista_compra/application/lista_compra_service.dart';
import '../../lista_favoritos/application/lista_favoritos_service.dart';
import '../../../shared/data_entities/models/lista_compra.dart';
import '../../../shared/data_entities/models/lista_favoritos.dart';
import '../../pantalla_producto/application/pantalla_producto_service.dart';

class DetallesProducto extends StatelessWidget {
  final Producto producto;
  final ListaCompraService listaCompraService = ListaCompraService();
  final ListaFavoritosService listaFavoritosService = ListaFavoritosService();
  final ListaCompra listaCompra;
  final ListaFavoritos listaFavoritos;
  final List<Producto> productosRelacionados = [];
  final PantallaProductoService pantallaProductoService = PantallaProductoService();

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
      appBar: AppBar(
        title: const Text('Detalles del producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: 185,
                height: 185,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 100);
                },
              )
                  : const Icon(Icons.image_not_supported, size: 100),
            ),
            const SizedBox(height: 16),

            Text(
              producto.nombre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 8),

            Text(
              '${producto.precio.toStringAsFixed(2)}€',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            Text(
              precioMedida,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Text(
              producto.marca,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            Text(
              producto.tienda,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Botones para agregar a la lista de compra o favoritos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Llamar al servicio para añadir a la lista de compra
                      listaCompraService.annadirProducto(listaCompra, producto);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${producto.nombre} añadido a la lista de compra')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al añadir a la lista de compra')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),),
                    padding: EdgeInsets.all(20),
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10), //Espacio entre los botones

                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Verificar si el producto ya está en favoritos
                      if (listaFavoritosService.productoEnFavoritos(listaFavoritos, producto)) {
                        // Mostrar un diálogo si el producto ya está en favoritos
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Producto ya en favoritos'),
                              content: Text('${producto.nombre} ya se encuentra en tu lista de favoritos.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Cierra el diálogo
                                  },
                                  child: Text('Ok'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // Añadir a favoritos si no está ya en la lista
                        listaFavoritosService.annadirProducto(listaFavoritos, producto);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${producto.nombre} añadido a favoritos')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al añadir a favoritos')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),),
                    padding: EdgeInsets.all(20),
                  ),
                  child: Icon(
                    Icons.favorite,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Aquí usar un Spacer para tomar el espacio disponible
            Spacer(),

            // Lista horizontal de productos relacionados con altura fija
            Container(
              height: 175, // Altura fija para la sección de productos relacionados
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Productos relacionados',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // FutureBuilder para manejar el Future<List<Producto>>
                  FutureBuilder<List<Producto>>(
                    future: pantallaProductoService.obtenerProductosSimilares(
                        PantallaProductoService.limpiarNombreProducto(producto.nombre), producto),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Mientras se obtiene la respuesta, icono de carga
                        return Padding(
                          padding: const EdgeInsets.only(top: 50.0), // Mover hacia abajo
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error al cargar productos relacionados.'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No hay productos relacionados.'));
                      } else {
                        List<Producto> productosRelacionados = snapshot.data!;

                        return Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: productosRelacionados.map((productoRelacionado) {
                                return GestureDetector(
                                  onTap: () {
                                    // Navegar a la pantalla de detalles del producto seleccionado
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
                                      children: [
                                        Image.network(
                                          productoRelacionado.foto,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.broken_image, size: 100);
                                          },
                                        ),
                                        const SizedBox(height: 8),
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
                                        Expanded(
                                          child: Text(
                                            productoRelacionado.tienda,
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Align(
                                          alignment: Alignment.topCenter,
                                          child: Text(
                                            '${productoRelacionado.precio.toStringAsFixed(2)}€',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}