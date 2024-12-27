import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/shared/application/producto_service.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/features/lista_favoritos/application/lista_favoritos_service.dart';

class ListaFavoritosInterfaz extends StatefulWidget {
  final ListaFavoritos listaFavoritos;
  final ListaCompra listaCompra;

  ListaFavoritosInterfaz({super.key, required this.listaFavoritos, required this.listaCompra});

  @override
  _ListaFavoritosInterfazState createState() => _ListaFavoritosInterfazState();
}

class _ListaFavoritosInterfazState extends State<ListaFavoritosInterfaz> {
  final ListaFavoritosService listaFavoritosService = ListaFavoritosService();
  final ListaCompraService listaCompraService = ListaCompraService();
  final ProductoService productoService = ProductoService();
  Map<String, TextEditingController> _mapaControladorCantidad = {};
  Map<String, bool> _mapaProductoConBotonCarrito = {};
  String? _mensajeAdvertencia;

  TextEditingController _crearCantidadController(Producto producto) {
    String key = productoService.generarClave(producto);
    if (!_mapaControladorCantidad.containsKey(key)) {
      _mapaControladorCantidad[key] = TextEditingController();
      _mapaControladorCantidad[key]!.text = listaCompraService.getCantidadProducto(widget.listaCompra, producto).toString();
    }
    return _mapaControladorCantidad[key]!;
  }

  void actualizarCantidadController(Producto producto) {
    _mapaControladorCantidad[productoService.generarClave(producto)]!.text = listaCompraService
        .getCantidadProducto(widget.listaCompra, producto)
        .toString();
  }

  void _manejadorTextField(String input) {
    /* Verificar que solo se introduzcan números */
    if (input.isNotEmpty && RegExp(r'[^0-9]').hasMatch(input)) {
      /* Si no es un número, mostrar un mensaje de advertencia*/
      setState(() {
        _mensajeAdvertencia = 'Solo números';
      });
      /* Evitar que se agregue el carácter no permitido */
      /* Esta parte lo hace imposible */
      _mapaControladorCantidad.forEach((key, controller) {
        controller.text = controller.text.substring(0, controller.text.length - 1);
      });
      Future.delayed(Duration(seconds: 2), () {
        /* Limpiar el mensaje de advertencia si han pasado 2 segundos */
        setState(() {
          _mensajeAdvertencia = null;
        });
      });
    } else {
      /* Limpiar el mensaje de advertencia si el input es válido */
      setState(() {
        _mensajeAdvertencia = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Lista de Favoritos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.listaFavoritos.productos.isEmpty
            ? Center(child: Text('Tu lista de favoritos está vacía.'))
            : Column(
          children: [
            if (_mensajeAdvertencia != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _mensajeAdvertencia!,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.listaFavoritos.productos.length,
                itemBuilder: (context, index) {
                  final producto = widget.listaFavoritos.productos[index];
                  final imageUrl = producto.foto;
                  final cantidad = listaCompraService.getCantidadProducto(widget.listaCompra, producto);

                  return Dismissible(
                    key: Key(productoService.generarClave(producto)),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) {
                      listaFavoritosService.quitarProducto(widget.listaFavoritos, producto);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      leading: producto.foto.isNotEmpty
                          ? Image.network(imageUrl, width: 50, height: 50, errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Icon(Icons.broken_image);
                      })
                          : Icon(Icons.image_not_supported),
                      title: Text(producto.nombre),
                      subtitle: Text('${producto.tienda} - €${producto.precio.toStringAsFixed(2)}'),
                      trailing: _mapaProductoConBotonCarrito[productoService.generarClave(producto)] == true
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (cantidad > 1) {
                                setState(() {
                                  listaCompraService.quitarInstancia(widget.listaCompra, producto);
                                  actualizarCantidadController(producto);
                                });
                              } else {
                                setState(() {
                                  listaCompraService.quitarProducto(widget.listaCompra, producto);
                                  _mapaProductoConBotonCarrito[productoService.generarClave(producto)] = false; /* Resetear al formato carrito */
                                });
                              }
                            },
                          ),
                          Container(
                            width: 50,
                            child: TextField(
                              controller: _crearCantidadController(producto),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: cantidad.toString(),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                              ),
                              textAlign: TextAlign.center,
                              onChanged: _manejadorTextField,
                              onSubmitted: (value) {
                                int newQuantity = int.tryParse(value) ?? cantidad;
                                if (newQuantity > 0) {
                                  setState(() {
                                    listaCompraService.setCantidadProducto(widget.listaCompra, producto, newQuantity);
                                    actualizarCantidadController(producto);
                                  });
                                } else {
                                  setState(() {
                                    listaCompraService.quitarProducto(widget.listaCompra, producto);
                                    _mapaProductoConBotonCarrito[productoService.generarClave(producto)] = false; /* Resetear al formato carrito */
                                  });
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() {
                                if(_mapaControladorCantidad[productoService.generarClave(producto)]!.text == "0") {
                                  listaCompraService.annadirProducto(widget.listaCompra, producto);
                                } else {
                                  listaCompraService.annadirInstancia(widget.listaCompra, producto);
                                }
                                actualizarCantidadController(producto);
                              });
                            },
                          ),
                        ],
                      )
                          : IconButton(
                        icon: Icon(Icons.shopping_cart),
                        onPressed: () {
                          setState(() {
                            _mapaProductoConBotonCarrito[productoService.generarClave(producto)] = true; /* Cambiar solo la interfaz */
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}