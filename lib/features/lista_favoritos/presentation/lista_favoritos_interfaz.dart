import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/shared/application/producto_service.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/features/lista_favoritos/application/lista_favoritos_service.dart';
import 'package:prizo/shared/application/icon_service.dart';

class ListaFavoritosInterfaz extends StatefulWidget {
  ListaFavoritos listaFavoritos;
  final ListaCompra listaCompra;
  final ListaFavoritos original;

  ListaFavoritosInterfaz({
    super.key,
    required this.listaFavoritos,
    required this.listaCompra,
    required this.original,
  });

  @override
  _ListaFavoritosInterfazState createState() => _ListaFavoritosInterfazState();
}

class _ListaFavoritosInterfazState extends State<ListaFavoritosInterfaz> {
  final ListaFavoritosService listaFavoritosService = ListaFavoritosService();
  final ListaCompraService listaCompraService = ListaCompraService();
  final ProductoService productoService = ProductoService();

  Map<String, int> _productoCantidad = {};
  Map<String, bool> _mapaProductoConBotonCarrito = {};
  List<String> tiendasSeleccionadas = [];
  final IconService iconService = new IconService();

  List<Producto> _filtrarProductos() {
    if (widget.original.productos.isEmpty) {
      return widget.original.productos;
    }
    if (tiendasSeleccionadas.isEmpty) {
      return widget.original.productos;
    }
    return widget.original.productos
        .where((producto) => tiendasSeleccionadas.contains(producto.tienda))
        .toList();
  }

  void _toggleTienda(String tienda) {
    setState(() {
      if (tiendasSeleccionadas.contains(tienda)) {
        tiendasSeleccionadas.remove(tienda);
      } else {
        tiendasSeleccionadas.add(tienda);
      }
      widget.listaFavoritos = ListaFavoritos(
        id: widget.original.id,
        usuario: widget.original.usuario,
        productos: _filtrarProductos(),
      );
    });
  }

  void _incrementarCantidad(Producto producto) {
    setState(() {
      _productoCantidad[productoService.generarClave(producto)] =
          (_productoCantidad[productoService.generarClave(producto)] ?? 0) + 1;
      listaCompraService.annadirInstancia(widget.listaCompra, producto);
    });
  }

  void _decrementarCantidad(Producto producto) {
    setState(() {
      final currentCantidad =
          _productoCantidad[productoService.generarClave(producto)] ?? 0;
      if (currentCantidad > 1) {
        _productoCantidad[productoService.generarClave(producto)] = currentCantidad - 1;
        listaCompraService.quitarInstancia(widget.listaCompra, producto);
      } else {
        _productoCantidad.remove(productoService.generarClave(producto));
        listaCompraService.quitarProducto(widget.listaCompra, producto);
        _mapaProductoConBotonCarrito[productoService.generarClave(producto)] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Tu Lista de Favoritos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _toggleTienda("DIA");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tiendasSeleccionadas.contains("DIA")
                        ? Color(0xFF95B3FF)
                        : Colors.white,
                    side: BorderSide(color: Color(0xFF95B3FF)),
                  ),
                  child: const Text('Día'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _toggleTienda("CONSUM");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tiendasSeleccionadas.contains("CONSUM")
                        ? Color(0xFF95B3FF)
                        : Colors.white,
                    side: BorderSide(color: Color(0xFF95B3FF)),
                  ),
                  child: const Text('Consum'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _toggleTienda("Carrefour");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tiendasSeleccionadas.contains("Carrefour")
                        ? Color(0xFF95B3FF)
                        : Colors.white,
                    side: BorderSide(color: Color(0xFF95B3FF)),
                  ),
                  child: const Text('Carrefour'),
                ),
              ],
            ),
            Expanded(
              child: widget.listaFavoritos.productos.isEmpty
                  ? Center(child: Text('Tu lista de favoritos está vacía.'))
                  : ListView.builder(
                itemCount: widget.listaFavoritos.productos.length,
                itemBuilder: (context, index) {
                  final producto =
                  widget.listaFavoritos.productos[index];
                  final imageUrl = producto.foto;
                  final cantidad = _productoCantidad[
                  productoService.generarClave(producto)] ??
                      listaCompraService.getCantidadProducto(
                          widget.listaCompra, producto);
                  return Dismissible(
                    key: Key(productoService.generarClave(producto)),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) {
                      listaFavoritosService.quitarProducto(
                          widget.listaFavoritos, producto);
                    },
                    background: Container(
                      color: Color(0xFF95B3FF),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Image.memory(iconService.getPapelera(),
                          width: 30, height: 30),
                    ),
                    child: ListTile(
                      leading: producto.foto.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                        errorBuilder:
                            (context, error, stackTrace) {
                          print('Error loading image: $error');
                          return Icon(Icons.broken_image);
                        },
                      )
                          : Icon(Icons.image_not_supported),
                      title: Text(producto.nombre),
                      subtitle: Text('${producto.tienda} - €${producto.precio.toStringAsFixed(2)}'),
                      trailing: _mapaProductoConBotonCarrito[productoService.generarClave(producto)] == true
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              _decrementarCantidad(producto);
                            },
                          ),
                          Text('$cantidad',
                              style: TextStyle(fontSize: 16)),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              _incrementarCantidad(producto);
                            },
                          ),
                        ],
                      )
                          : IconButton(
                        icon: Image.memory(
                          iconService.getCesta(),
                          width: 30,
                          height: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _mapaProductoConBotonCarrito[productoService.generarClave(producto)] = true;
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Color(0xFF95B3FF),
                          padding: EdgeInsets.all(20),
                        ),
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