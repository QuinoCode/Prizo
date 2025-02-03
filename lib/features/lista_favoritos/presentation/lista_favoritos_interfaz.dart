// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:prizo/features/pantalla_producto/presentation/pantalla_producto_interfaz.dart';
import 'package:prizo/features/productsearch/product_search_ui.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/shared/application/producto_service.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/features/lista_favoritos/application/lista_favoritos_service.dart';
import 'package:prizo/shared/application/icon_service.dart';
import 'package:prizo/shared/database/database_operations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:prizo/features/lista/lista.dart';


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
        leading:
        IconButton(
          padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.shortestSide*0.057,0,0,0),
          icon: ImageIcon(AssetImage('assets/icons/arrow.png')),
          splashColor: Colors.transparent,
          color: Color.fromARGB(255,18,18,18),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        surfaceTintColor: Colors.transparent,
        title: Text('Lista de favoritos'),
        centerTitle: true,
        toolbarHeight: MediaQuery.of(context).size.longestSide * 0.092,
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Color.fromARGB(255,18,18,18), fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.0644, fontWeight: FontWeight.w500),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(18,16,15,16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0,0,7,0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.longestSide * 0.0379,
                      width: MediaQuery.of(context).size.shortestSide * 0.169,
                      child: ElevatedButton(
                        onPressed: () => _toggleTienda("DIA"),
                        style: ElevatedButton.styleFrom(
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          backgroundColor: tiendasSeleccionadas.contains("DIA") ? Color(0xFF95B3FF) : Colors.white,
                          foregroundColor: Color.fromARGB(255,80,79,79),
                          side: BorderSide(color: Color.fromARGB(255,149,179,255),width: 2),
                        ),
                        child: Text('DIA', 
                          style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.0322, fontWeight: FontWeight.w400)
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.longestSide * 0.0379,
                      width: MediaQuery.of(context).size.shortestSide * 0.274,
                      child: ElevatedButton(
                        onPressed: () => _toggleTienda("CONSUM"),
                        style: ElevatedButton.styleFrom(
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          backgroundColor: tiendasSeleccionadas.contains("CONSUM") ? Color(0xFF95B3FF) : Colors.white,
                          foregroundColor: Color.fromARGB(255,80,79,79),
                          side: BorderSide(color: Color(0xFF95B3FF),width: 2),
                        ),
                        child: Text('Consum',
                          style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.0322, fontWeight: FontWeight.w400)
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.longestSide * 0.0379,
                      width: MediaQuery.of(context).size.shortestSide * 0.305,
                      child: ElevatedButton(
                        onPressed: () => _toggleTienda("Carrefour"),
                        style: ElevatedButton.styleFrom(
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          backgroundColor: tiendasSeleccionadas.contains("Carrefour") ? Color(0xFF95B3FF) : Colors.white,
                          foregroundColor: Color.fromARGB(255,80,79,79),
                          side: BorderSide(color: Color(0xFF95B3FF),width: 2),
                        ),
                        child: Text('Carrefour',
                          style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.0322, fontWeight: FontWeight.w400)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: widget.listaFavoritos.productos.isEmpty 
                ? Center(
                  child: Text('Tu lista de favoritos está vacía.',
                    style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.0322, fontWeight: FontWeight.w400))
                )
                : ListView.builder(
                  itemCount: widget.listaFavoritos.productos.length,
                  itemBuilder: (context, index) {
                    final producto =
                    widget.listaFavoritos.productos[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                        child: Dismissible(
                          key: Key(productoService.generarClave(producto)),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (direction) {
                            setState(() {
                              listaFavoritosService.quitarProducto(widget.listaFavoritos, producto);
                              listaFavoritosService.DB_quitarProducto(producto);
                              widget.listaFavoritos = ListaFavoritos(
                                id: widget.original.id,
                                usuario: widget.original.usuario,
                                productos: List.from(widget.listaFavoritos.productos)..remove(producto),
                              );
                            });
                          },
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(color: Color(0xFF95B3FF), borderRadius: BorderRadius.circular(23)),
                            child: ImageIcon(AssetImage('assets/icons/basura.png'), size: MediaQuery.of(context).size.shortestSide * 0.0872)
                          ),
                          child: StatefulStoreItem(producto: producto,)
                        ),
                      ),
                    );
                  },
                ),
              ),
          ]
        ),
      ),
    );
  }
}

class StatefulStoreItem extends StatefulWidget {
  final Producto producto;
  const StatefulStoreItem({super.key, required this.producto});

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

  String shortenText(String nombre){
    if(nombre.length >= 18){
      return nombre.substring(0,18) + '...';
    } else {
      return nombre;
    }
  }

  void _navigateToProductInfo(Producto producto) {
    ListaCompra listaCompra = ListaCompra(id: '1', usuario: 'usuario_demo', productos: []);
    ListaFavoritos listaFavoritos = ListaFavoritos(id: '1', usuario: 'usuario_demo', productos: []);
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
    Database db = DatabaseOperations.instance.prizoDatabase;
    final ListaCompraService listaCompraService = ListaCompraService();
    return Container(
      decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(23), // Rounded corners
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _navigateToProductInfo(widget.producto),
            child: Image.network(
              widget.producto.foto,
              width: MediaQuery.of(context).size.shortestSide * 0.205,
              height: MediaQuery.of(context).size.shortestSide * 0.205,
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.shortestSide * 0.007),
          SizedBox(
            height: MediaQuery.of(context).size.longestSide * 0.12,
            child: VerticalDivider(
              thickness: 1,
              color: Color.fromARGB(255,175,198,255),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.shortestSide * 0.03),
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToProductInfo(widget.producto),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.shortestSide * 0.283,
                      child:
                      Text(
                        shortenText(widget.producto.nombre),
                        maxLines: 2,
                        style: TextStyle(
                          height: 1.2,
                          fontFamily: 'Geist',
                          color: Color.fromARGB(255,18,18,18),
                          fontSize: MediaQuery.of(context).size.shortestSide * 0.04293,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                  ),
                  SizedBox(height: MediaQuery.of(context).size.longestSide * 0.001),
                  Text(
                    widget.producto.tienda,
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w300,
                      color: Color.fromARGB(255,33,33,33),
                      fontSize: MediaQuery.of(context).size.shortestSide * 0.04293,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.shortestSide * 0.023),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.producto.precio}€',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          color: Color.fromARGB(255,33,33,33),
                          fontSize: MediaQuery.of(context).size.shortestSide * 0.04293,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.shortestSide * 0.01),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0,3,0,0),
                        child: Text(
                          '${widget.producto.precioMedida}€/kg',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            color: Color.fromARGB(255,53,53,53),
                            fontSize: MediaQuery.of(context).size.shortestSide * 0.0322,
                          ),
                        ),
                      ),
                    ]
                  ),
                ],
              ),
            )
          ),
          SizedBox(width: MediaQuery.of(context).size.shortestSide * 0.051),
          SizedBox(
            child: _showButton
              ? Container(
                height: MediaQuery.of(context).size.longestSide * 0.0473,
                width: MediaQuery.of(context).size.shortestSide * 0.21,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 149, 179, 252),
                    borderRadius: BorderRadius.circular(20)
                ),
                child:IconButton(
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
                  icon: ImageIcon(AssetImage('assets/icons/shopping_basket.png'), size: MediaQuery.of(context).size.shortestSide * 0.0615, color: Color.fromARGB(255,18,18,18))
                )
              )
              : Container(
                height: MediaQuery.of(context).size.longestSide * 0.0473,
                width: MediaQuery.of(context).size.shortestSide * 0.21,
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
                      right: MediaQuery.of(context).size.shortestSide * 0.097,
                      child: IconButton(
                        iconSize: MediaQuery.of(context).size.shortestSide * 0.06,
                        padding: EdgeInsets.zero,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (_counter > 0) {
                              //DatabaseOperations.instance.decreaseCantidadListaCompra(db, widget.producto);
                              listaCompraService.DB_decreaseCantidad(widget.producto);
                              _counter--;
                            } else {
                              //DatabaseOperations.instance.deleteFromListaCompraTable(db, widget.producto);
                              listaCompraService.DB_quitarProducto(widget.producto);
                              listaCompraService.DB_Tick_quitar(widget.producto);
                              _showButton = true;
                            }
                          });
                        },
                      ),
                    ),
                    Positioned(
                      left: _counter > 10
                          ? _counter > 19
                          ? MediaQuery.of(context).size.shortestSide * 0.075
                          : MediaQuery.of(context).size.shortestSide * 0.082
                          : MediaQuery.of(context).size.shortestSide * (_counter == 1 ? 0.098 : 0.09),
                      top: MediaQuery.of(context).size.longestSide * (_counter < 10 ? 0.004 : 0.007),
                      bottom: 0,
                      child: Text('$_counter',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.shortestSide * (_counter < 10 ? 0.06 : 0.053),
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: MediaQuery.of(context).size.longestSide * 0.001,
                      left: MediaQuery.of(context).size.shortestSide * 0.1,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        icon: Icon(Icons.add, size: MediaQuery.of(context).size.shortestSide * 0.06),
                        onPressed: () {
                          if (_counter < 99) {
                            //DatabaseOperations.instance.increaseCantidadListaCompra(db, widget.producto);
                            listaCompraService.DB_increaseCantidad(widget.producto);
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
    );
  }
}