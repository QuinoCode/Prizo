import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:prizo/features/pantalla_producto/presentation/pantalla_producto_interfaz.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/shared/application/producto_service.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/features/lista_favoritos/application/lista_favoritos_service.dart';
import 'package:prizo/shared/application/icon_service.dart';
import 'package:prizo/shared/database/database_operations.dart';
import 'package:sqflite/sqflite.dart';

Database db = DatabaseOperations.instance.prizoDatabase;
ListaCompra listaCompra = ListaCompra(
    id: '1', usuario: 'usuario_demo', productos: []);
ListaFavoritos listaFavoritos = ListaFavoritos(
    id: '1', usuario: 'usuario_demo', productos: []);

    
String shortenText(String nombre, int limit, String replacement){
  if(nombre.length > limit){
    return nombre.substring(0,limit) +replacement;
  } else {
    return nombre;
  }
}


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
                      listaFavoritosService.DB_quitarProducto(producto);
                    },
                    background: Container(
                      //color: Color(0xFF95B3FF),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Image.memory(iconService.getPapelera(),
                          width: 30, height: 30),
                      decoration: BoxDecoration(color: Color(0xFF95B3FF), borderRadius: BorderRadius.circular(23)),
                    ),
                    child: StatefulStoreItem(producto: producto,)
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

class StatefulStoreItem extends StatefulWidget {
  final Producto producto;
  const StatefulStoreItem({required this.producto});

  @override
  _ProductTileItemState createState() => _ProductTileItemState();
}

class _ProductTileItemState extends State<StatefulStoreItem> {
  bool _showButton = true;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _counter = 0;
  }


  void _navigateToProductInfo(Producto producto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
          DetallesProducto(producto: producto, listaCompra: listaCompra, listaFavoritos: listaFavoritos,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _navigateToProductInfo(widget.producto),
                child: Image.network(
                  widget.producto.foto,
                  width: MediaQuery.of(context).size.width * 0.279,
                  height: MediaQuery.of(context).size.height * 0.128,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.007), 
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.128,
                child: VerticalDivider(
                  thickness: 1,
                  color: Color.fromARGB(255,175,198,255),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.03), 
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _navigateToProductInfo(widget.producto);
                  },
                  child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.283,
                          child:
                            Text(
                              shortenText(widget.producto.nombre, 18, '...'),
                              maxLines: 2,
                              style: TextStyle(
                                    height: 1.2,
                                    fontFamily: 'Geist',
                                    color: Color.fromARGB(255,18,18,18),
                                    fontSize: MediaQuery.of(context).size.width * 0.04,
                                    fontWeight: FontWeight.w500,
                                  ),
                            )
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                        Text(
                          widget.producto.tienda,
                          style: TextStyle(
                                fontFamily: 'Geist',
                                fontWeight: FontWeight.w300,
                                color: Color.fromARGB(255,33,33,33),
                                fontSize: MediaQuery.of(context).size.width * 0.0332,
                              ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.width * 0.023),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              '${widget.producto.precio}€',
                              style: TextStyle(
                                  fontFamily: 'Geist',
                                  color: Color.fromARGB(255,33,33,33),
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                  fontWeight: FontWeight.w500,
                                ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.014),
                            Text(
                              '${widget.producto.precioMedida}€/kg',
                              style: TextStyle(
                                  fontFamily: 'Geist',
                                  color: Color.fromARGB(255,53,53,53),
                                  fontSize: MediaQuery.of(context).size.width * 0.028,
                                ),
                            ),
                          ]
                        ),
                      ],
                    ),
                )
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.051), 
              SizedBox(
                child: _showButton
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.0473,
                      width: MediaQuery.of(context).size.width * 0.21,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 149, 179, 252),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child:
                      IconButton(
                        onPressed: () {
                          DatabaseOperations.instance.existsInProductTable(db, widget.producto).then((exists) {
                            if (exists) {
                              DatabaseOperations.instance.fetchCantidadListaCompra(db, widget.producto).then((cantidad) {
                                setState(() {
                                  _counter = cantidad;  // Set _counter to the fetched cantidad
                                  _showButton = false; // Update _showButton only if the product exists in the table
                                });
                              });
                            } else {
                              DatabaseOperations.instance.registerIntoProductTable(db, widget.producto).then((_) {});
                              setState(() {
                                _showButton = false; // Update _showButton after inserting the product
                              });
                            }
                          });
                        },
                        color: Color.fromARGB(255, 80, 79, 79),
                        icon: ImageIcon(AssetImage('assets/icons/shopping_basket.png'), size: MediaQuery.of(context).size.width * 0.0615, color: Color.fromARGB(255,18,18,18))
                      )
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height * 0.0473,
                      width: MediaQuery.of(context).size.width * 0.21,
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 246, 246, 246),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            bottom: 0,
                            right: MediaQuery.of(context).size.width * 0.097,
                            child: IconButton(
                              iconSize: MediaQuery.of(context).size.width * 0.06,
                              padding: EdgeInsets.zero,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,  
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (_counter > 0) {
                                    DatabaseOperations.instance.decreaseCantidadListaCompra(db, widget.producto);
                                    _counter--;
                                  } else {
                                    DatabaseOperations.instance.deleteFromListaCompraTable(db, widget.producto);
                                    _showButton = true;
                                  }
                                });
                              },
                            ),
                          ),
                          Positioned(
                              left: _counter > 10
                                    ? _counter > 19
                                      ? MediaQuery.of(context).size.width * 0.075
                                      : MediaQuery.of(context).size.width * 0.082
                                  : MediaQuery.of(context).size.width * (_counter == 1 ? 0.098 : 0.09),
                              top: MediaQuery.of(context).size.height * (_counter < 10 ? 0.004 : 0.007),
                              bottom: 0,
                              child: Text(
                                '$_counter',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width *
                                      (_counter < 10 ? 0.06 : 0.053),
                                  fontFamily: 'Geist',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          Positioned(
                            top: 0,
                            bottom: MediaQuery.of(context).size.height * 0.001,
                            left: MediaQuery.of(context).size.width * 0.1,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,  
                              icon: Icon(Icons.add, size: MediaQuery.of(context).size.width * 0.06),
                              onPressed: () {
                                if (_counter < 99) {
                                  DatabaseOperations.instance.increaseCantidadListaCompra(db, widget.producto);
                                  setState(() {
                                    _counter++;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                )
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.0098),
      ]
    );
  }
}