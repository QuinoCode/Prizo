import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/producto.dart';
import 'package:prizo/shared/data_entities/lista_compra.dart';
import 'package:prizo/shared/data_entities/lista_favoritos.dart';
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
  Map<String, TextEditingController> _cantidadControllers = {}; // Mapa de controladores
  String? _warningMessage; // Mensaje de advertencia

  // Crear el controlador para cada producto
  TextEditingController _getCantidadController(Producto producto) {
    String key = productoService.generateKey(producto);
    if (!_cantidadControllers.containsKey(key)) {
      // Si no existe el controlador, lo creamos
      _cantidadControllers[key] = TextEditingController();
      _cantidadControllers[key]!.text = listaCompraService.getProductQuantity(widget.listaCompra, producto).toString();
    }
    return _cantidadControllers[key]!;
  }

  // Función que maneja el input numérico en el TextField
  void _handleInputChange(String input) {
    // Verificar que solo se introduzcan números
    if (input.isNotEmpty && RegExp(r'[^0-9]').hasMatch(input)) {
      // Si no es un número, mostrar un mensaje de advertencia
      setState(() {
        _warningMessage = 'Solo números';
      });

      // Eliminar el último carácter no numérico
      _cantidadControllers.forEach((key, controller) {
        controller.text = controller.text.substring(0, controller.text.length - 1);
      });

      // Eliminar el mensaje de advertencia después de 2 segundos
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _warningMessage = null;
        });
      });
    } else {
      setState(() {
        _warningMessage = null;  // Limpiar el mensaje de advertencia si el input es válido
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tu Lista de Favoritos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.listaFavoritos.productos.isEmpty
            ? Center(child: Text('Tu lista de favoritos está vacía.'))
            : Column(
          children: [
            // Mostrar el mensaje de advertencia (si existe)
            if (_warningMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _warningMessage!,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            // Lista de productos
            Expanded(
              child: ListView.builder(
                itemCount: widget.listaFavoritos.productos.length,
                itemBuilder: (context, index) {
                  final producto = widget.listaFavoritos.productos[index];
                  final imageUrl = producto.foto;
                  final cantidad = listaCompraService.getProductQuantity(widget.listaCompra, producto);

                  return Dismissible(
                    key: Key(productoService.generateKey(producto)),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) {
                      listaFavoritosService.removeProduct(widget.listaFavoritos, producto);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      leading: producto.foto.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          return Icon(Icons.broken_image);
                        },
                      )
                          : Icon(Icons.image_not_supported),
                      title: Text(producto.nombre),
                      subtitle: Text('${producto.tienda} - €${producto.precio.toStringAsFixed(2)}'),
                      trailing: cantidad == -1 // Si el producto no está en la lista de la compra, mostrar el carrito
                          ? IconButton(
                        icon: Icon(Icons.shopping_cart),
                        onPressed: () {
                          setState(() {
                            listaCompraService.addProduct(widget.listaCompra, producto);
                          });
                        },
                      )
                          : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Botón "-" para eliminar una instancia
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (cantidad > 1) {
                                setState(() {
                                  listaCompraService.removeInstance(widget.listaCompra, producto);
                                  _cantidadControllers[productoService.generateKey(producto)]!.text =
                                      listaCompraService.getProductQuantity(widget.listaCompra, producto).toString();
                                });
                              } else {
                                setState(() {
                                  listaCompraService.removeProduct(widget.listaCompra, producto);
                                });
                              }
                            },
                          ),
                          // Campo de cantidad con un TextField para editar
                          Container(
                            width: 50,
                            child: TextField(
                              controller: _getCantidadController(producto),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: cantidad.toString(),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                              ),
                              textAlign: TextAlign.center,
                              onChanged: _handleInputChange,
                              onSubmitted: (value) {
                                int newQuantity = int.tryParse(value) ?? cantidad;
                                if (newQuantity > 0) {
                                  setState(() {
                                    listaCompraService.setProductQuantity(widget.listaCompra, producto, newQuantity);
                                    _cantidadControllers[productoService.generateKey(producto)]!.text =
                                        listaCompraService.getProductQuantity(widget.listaCompra, producto).toString();
                                  });
                                } else {
                                  setState(() {
                                    listaCompraService.removeProduct(widget.listaCompra, producto);
                                  });
                                }
                              },
                            ),
                          ),
                          // Botón "+" para agregar una instancia
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() {
                                listaCompraService.addInstance(widget.listaCompra, producto);
                                _cantidadControllers[productoService.generateKey(producto)]!.text =
                                    listaCompraService.getProductQuantity(widget.listaCompra, producto).toString();
                              });
                            },
                          ),
                        ],
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