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
import 'package:provider/provider.dart';
import 'package:prizo/main.dart';


class ListaFavoritosInterfaz extends StatefulWidget {
  ListaFavoritosInterfaz({super.key});

  @override
  _ListaFavoritosInterfazState createState() => _ListaFavoritosInterfazState();
}

class _ListaFavoritosInterfazState extends State<ListaFavoritosInterfaz> {
  Map<String, int> _productoCantidad = {};
  Map<String, bool> _mapaProductoConBotonCarrito = {};
  List<String> tiendasSeleccionadas = [];
  final ListaFavoritosService listaFavoritosService = ListaFavoritosService();
  final ListaCompraService listaCompraService = ListaCompraService();
  final ProductoService productoService = ProductoService();
  ListaFavoritos listaFavoritos = ListaFavoritos(id: '1', usuario: 'usuario_demo', productos: []);
  ListaCompra listaCompra = ListaCompra(id: '1', usuario: 'usuario_demo', productos: []);
  bool _isLoading = true;

  List<Producto> _filtrarProductos() {
    if (listaFavoritos.productos.isEmpty) {
      return listaFavoritos.productos;
    }
    if (tiendasSeleccionadas.isEmpty) {
      return listaFavoritos.productos;
    }
    return listaFavoritos.productos
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
      listaFavoritos = ListaFavoritos(
        id: listaFavoritos.id,
        usuario: listaFavoritos.usuario,
        productos: _filtrarProductos(),
      );
    });
  }

  void _incrementarCantidad(Producto producto) {
    setState(() {
      _productoCantidad[productoService.generarClave(producto)] = (_productoCantidad[productoService.generarClave(producto)] ?? 0) + 1;
      listaCompraService.annadirInstancia(listaCompra, producto);
    });
  }

  void _decrementarCantidad(Producto producto) {
    setState(() {
      final currentCantidad = _productoCantidad[productoService.generarClave(producto)] ?? 0;
      if (currentCantidad > 1) {
        _productoCantidad[productoService.generarClave(producto)] = currentCantidad - 1;
        listaCompraService.quitarInstancia(listaCompra, producto);
      } else {
        _productoCantidad.remove(productoService.generarClave(producto));
        _mapaProductoConBotonCarrito[productoService.generarClave(producto)] = false;
        listaCompraService.quitarProducto(listaCompra, producto);
      }
    });
  }
  
  void _initListas() async{
    ListaCompra fetchedListaC = await listaCompraService.generar_ListaCompra();
    ListaFavoritos fetchedListaF = await listaFavoritosService.generar_ListaFavoritos();
    setState(() {
       listaCompra = fetchedListaC;
       listaFavoritos = fetchedListaF;
       _isLoading = false;
    });
  }

  @override
  void didUpdateWidget(ListaFavoritosInterfaz oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      setState (() {
      }); // llamar a init otra vez
    }
  }

  @override
  void initState() {
    super.initState();
    _initListas();
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
            Provider.of<PrizoState>(context, listen: false).setIndex(2);
          },
        ),
        surfaceTintColor: Colors.transparent,
        title: Text('Lista de favoritos'),
        centerTitle: true,
        toolbarHeight: MediaQuery.of(context).size.longestSide * 0.092,
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Color.fromARGB(255,18,18,18), fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.0644, fontWeight: FontWeight.w500),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.shortestSide * 0.0550),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dia button
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
                        style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.04293, fontWeight: FontWeight.w400)
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
                        style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.04293, fontWeight: FontWeight.w400)
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
                        style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.04293, fontWeight: FontWeight.w400)
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.longestSide * 0.034),
            Expanded(
              child: 
            _isLoading 
            ? Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.longestSide * 0.17),
              child: SizedBox(
                  height: MediaQuery.of(context).size.longestSide * 0.264,
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF95B3FF), ))
                ),
            )
            : listaFavoritos.productos.isEmpty 
              ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/bolsa_de_tela_vacia.png', height: MediaQuery.of(context).size.longestSide * 0.18),
                    SizedBox(height: MediaQuery.of(context).size.longestSide * 0.0318 ,),
                    Text('Tu lista de favoritos está vacía.',
                      style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.0322, fontWeight: FontWeight.w400)),
                    SizedBox(height: MediaQuery.of(context).size.longestSide * 0.17 ,),
                  ],
                )
              )
              : Padding(
                padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.shortestSide * 0.0550, 0, MediaQuery.of(context).size.shortestSide * 0.0550, MediaQuery.of(context).size.longestSide * 0.1),
                child: ListView.builder(
                  itemCount: listaFavoritos.productos.length,
                  itemBuilder: (context, index) {
                    final producto =
                    listaFavoritos.productos[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.longestSide * 0.0218),
                      child: Dismissible(
                        key: Key(productoService.generarClave(producto)),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) {
                          setState(() {
                            listaFavoritosService.quitarProducto(listaFavoritos, producto);
                            listaFavoritosService.DB_quitarProducto(producto);
                            listaFavoritos = ListaFavoritos(
                              id: listaFavoritos.id,
                              usuario: listaFavoritos.usuario,
                              productos: List.from(listaFavoritos.productos)..remove(producto),
                            );
                          });
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(color: Color(0xFF95B3FF), borderRadius: BorderRadius.circular(23)),
                          child: ImageIcon(AssetImage('assets/icons/basura.png'), size: MediaQuery.of(context).size.shortestSide * 0.0872)
                        ),
                        child: StatefulStoreItem(producto: producto, onReturn: _initListas,)
                      ),
                    );
                  },
                ),
              ),
            ),
        ]
      ),
    );
  }
}

class StatefulStoreItem extends StatefulWidget {
  final Producto producto;
  final VoidCallback onReturn;
  const StatefulStoreItem({super.key, required this.producto, required this.onReturn});

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

  void _navigateToProductInfo(Producto producto) async{
    ListaCompra listaCompra = ListaCompra(id: '1', usuario: 'usuario_demo', productos: []);
    ListaFavoritos listaFavoritos = ListaFavoritos(id: '1', usuario: 'usuario_demo', productos: []);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetallesProducto(producto: producto, listaCompra: listaCompra, listaFavoritos: listaFavoritos,),
      ),
    );
    widget.onReturn();
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
            child: widget.producto.foto.startsWith('assets')
            ? SizedBox(
              width: MediaQuery.of(context).size.shortestSide * 0.205,
              height: MediaQuery.of(context).size.shortestSide * 0.205,
              child: Center(
                child: Image.asset(
                    'assets/images/placeholder.png',
                    width: MediaQuery.of(context).size.shortestSide * 0.140,
                  ),
              ),
            )
            : Image.network(
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
                      right: MediaQuery.of(context).size.shortestSide * 0.110,
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
                      left: (MediaQuery.of(context).size.shortestSide * 0.21 - 
                      (TextPainter(
                        text: TextSpan(
                          text: '$_counter',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.shortestSide * 0.0644,
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        textDirection: TextDirection.ltr,
                      )..layout()).width)/2,
                      bottom: MediaQuery.of(context).size.longestSide * 0.002,
                      child: Text('$_counter',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.shortestSide * 0.0644,
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: MediaQuery.of(context).size.longestSide * 0.002,
                      left: MediaQuery.of(context).size.shortestSide * 0.110,
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
