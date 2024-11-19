import 'package:flutter/material.dart';
import '../../../shared/data_entities/producto.dart';
import '../../lista_compra/application/lista_compra_service.dart';
import '../../lista_favoritos/application/lista_favoritos_service.dart';
import '../../../shared/data_entities/lista_compra.dart';
import '../../../shared/data_entities/lista_favoritos.dart';
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
                width: 200,
                height: 200,
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                      listaCompraService.addProduct(listaCompra, producto);
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
                      // Llamar al servicio para añadir a la lista de favoritos
                      listaFavoritosService.addProduct(listaFavoritos, producto);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${producto.nombre} añadido a favoritos')),
                      );
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
            const SizedBox(height: 40),

            const SizedBox(height: 20),

            // Lista horizontal de productos relacionados
            Text(
              'Productos relacionados',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // FutureBuilder para manejar el Future<List<Producto>>
            FutureBuilder<List<Producto>>(
              future: pantallaProductoService.obtenerProductosSimilares(PantallaProductoService.limpiarNombreProducto(producto.nombre), producto),
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
                  // Si los productos están disponibles, mostramos la lista horizontal
                  List<Producto> productosRelacionados = snapshot.data!;

                  return SingleChildScrollView(
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
                                  width: 70,
                                  height: 70,
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
                                    overflow: TextOverflow.visible,
                                    maxLines: 3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  productoRelacionado.tienda,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.bottomCenter,
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
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}