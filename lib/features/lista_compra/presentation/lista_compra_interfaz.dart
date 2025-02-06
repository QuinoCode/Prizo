// ignore_for_file: library_private_types_in_public_api

import 'package:prizo/shared//database/database_operations.dart';
import 'package:flutter/material.dart';
import 'package:prizo/features/pantalla_producto/presentation/pantalla_producto_interfaz.dart';
import 'package:prizo/shared/application/producto_service.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/shared/data_entities/DAO/lista_compra_DAO.dart';
import 'package:provider/provider.dart';
import 'package:prizo/main.dart';

class ListaCompraInterfaz extends StatefulWidget {
  ListaCompraInterfaz({super.key});

  @override
  _ListaCompraInterfazState createState() => _ListaCompraInterfazState();
}

class _ListaCompraInterfazState extends State<ListaCompraInterfaz> with WidgetsBindingObserver {
  List<String> tiendasSeleccionadas = [];
  final ProductoService productoService = ProductoService();
  final ListaCompraService listaCompraService = ListaCompraService();
  ListaCompra listaCompra = ListaCompra(id: '1', usuario: 'usuario_demo', productos: []);

  void _initListaCompra() async{
    ListaCompra fetchedLista = await listaCompraService.generar_ListaCompra();
    setState(() {
       listaCompra = fetchedLista;
    });
  }
  @override
  void initState() {
    super.initState();
    _initListaCompra();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  void updateTheList(int counter, Producto producto, int tickStatus){
    for (var i = 0; i < listaCompra.productos.length; i++) {
        if (listaCompra.productos[i].$1 == producto) {
          // Update the second integer by incrementing it
          listaCompra.productos[i] = (listaCompra.productos[i].$1, counter, tickStatus);
        }
    }
    ListaCompra list = listaCompra;
    print(list);
    
  }
  Future<void> saveChangesIfDirty(bool isDirty, ListaCompra providedList) async {
    ListaCompraDAO dao = ListaCompraDAO(DatabaseOperations.instance.prizoDatabase);
    if (isDirty) {
      await dao.insertListaCompra(listaCompra); // Call your existing saveData method
    }
  }
  List<(Producto, int, int)> _filtrarProductos() {
    if (tiendasSeleccionadas.isEmpty) {
      return listaCompra.productos;
    }
    return listaCompra.productos.where((producto) => tiendasSeleccionadas.contains(producto.$1.tienda)).toList();
  }

  void _toggleTienda(String tienda) {
    setState(() {
      if (tiendasSeleccionadas.contains(tienda)) {
        tiendasSeleccionadas.remove(tienda);
      } else {
        tiendasSeleccionadas.add(tienda);
      }
    });
    _filtrarProductos();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // Access _isDirty from PrizoState (if it's global)
      final prizoState = Provider.of<PrizoState>(context, listen: false);
      if (prizoState.isDirty) {
        await saveChangesIfDirty(prizoState.isDirty, listaCompra);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.shortestSide*0.057, 0, 0, 0),
          icon: ImageIcon(AssetImage('assets/icons/arrow.png')),
          color: Color.fromARGB(255,18,18,18),
          splashColor: Colors.transparent,
          onPressed: () async {
            await saveChangesIfDirty(Provider.of<PrizoState>(context, listen: false).isDirty, listaCompra);
            Provider.of<PrizoState>(context, listen: false).setIndex(2);
          },
        ),
        surfaceTintColor: Colors.transparent,
        title: Text('Lista de compra'),
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
                //Consum Button
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
                //Carrefour Button
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
            child: listaCompra.productos.isEmpty
              ? Center(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/cesta_vacia.png', height: MediaQuery.of(context).size.longestSide * 0.18),
                  SizedBox(height: MediaQuery.of(context).size.longestSide * 0.0318 ,),
                    Text('Tu lista de la compra está vacía.',
                      style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.0322, fontWeight: FontWeight.w400)),
                  SizedBox(height: MediaQuery.of(context).size.longestSide * 0.17 ,),
                  ],
                ),
              ) 
              : Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.shortestSide * 0.0550),
                child: ListView.builder(
                  itemCount: listaCompra.productos.length,
                  itemBuilder: (context, index) {
                    final producto = listaCompra.productos[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.longestSide * 0.0218),
                      child: Dismissible(
                          key: Key(producto.$1.nombre),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (direction) {
                            setState(() {
                              bool thing = Provider.of<PrizoState>(context, listen: false).isDirty;
                              Provider.of<PrizoState>(context, listen: false).isDirty = true;
                              bool thingAfter = Provider.of<PrizoState>(context, listen: false).isDirty;
                              listaCompraService.quitarProducto(producto.$1);
                              listaCompra.productos.removeAt(index);
                            });
                          },
                          background: AnimatedSize(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(color: Color(0xFF95B3FF), borderRadius: BorderRadius.circular(23)),
                              child: ImageIcon(AssetImage('assets/icons/basura.png'), size: MediaQuery.of(context).size.shortestSide * 0.0872)
                            ),
                          ),
                          child: StatefulStoreItem(producto: producto, onUpdate: updateTheList, onReturn: _initListaCompra,)
                      ),
                    );
                  },
                ),
              ),
          )
        ],
      ),
    );
  }
}

class StatefulStoreItem extends StatefulWidget {
  (Producto,int,int) producto;
  final VoidCallback onReturn;
  final Function(int,Producto,int) onUpdate;

  StatefulStoreItem({super.key, required this.producto, required this.onUpdate, required this.onReturn});

  @override
  _ProductTileItemState createState() => _ProductTileItemState();
}

class _ProductTileItemState extends State<StatefulStoreItem> {
  ListaCompraService listaCompraService = ListaCompraService();
  bool _showButton = true;
  int _counter = 1;

  @override
  void initState() {
    super.initState();
    _counter = widget.producto.$2;
    _showButton = widget.producto.$3 == 0;
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

  String shortenText(String nombre){
    if(nombre.length >= 18){
      return '${nombre.substring(0,18)}...';
    } else {
      return nombre;
    }
  }

  /*Future<void> _ventanaConfirmacion(BuildContext context, Producto producto) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, /* Evita cerrar el diálogo tocando fuera de él */
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Eliminar producto?',
            style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.04293, fontWeight: FontWeight.w500),),
          content: Text('¿Estás seguro de que deseas eliminar el producto ${producto.nombre}?',
              style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.0322, fontWeight: FontWeight.w400)),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar',
                  style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.0322, fontWeight: FontWeight.w400)),
            ),
            TextButton(
              onPressed: () {

                Navigator.of(context).pop(); /* Cerrar el cuadro de diálogo */
              },
              child: Text('Eliminar',
                style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.0322, fontWeight: FontWeight.w400)),
            ),
          ],
        );
      },
    );
  }*/

  @override
  Widget build(BuildContext context) {
    Producto producto = widget.producto.$1;

    return Row(
      children: [
        GestureDetector(
          onTap: () => _navigateToProductInfo(producto),
          child: producto.foto.startsWith('assets')
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
            producto.foto,
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
            onTap: () => _navigateToProductInfo(producto),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.shortestSide * 0.283,
                    child:
                    Text(
                      shortenText(producto.nombre),
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
                  producto.tienda,
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255,33,33,33),
                    fontSize: MediaQuery.of(context).size.shortestSide * 0.0322,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.shortestSide * 0.023),
                Text(
                  '${(producto.precio * _counter).toStringAsFixed(2)}€',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    color: Color.fromARGB(255,33,33,33),
                    fontSize: MediaQuery.of(context).size.shortestSide * 0.04293,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.shortestSide * 0.023),
              ],
            ),
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.shortestSide * 0.053),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _showButton
                ? IconButton(
                padding: EdgeInsets.zero,
                icon: Image.asset('assets/icons/empty_checkbox.png', width: MediaQuery.of(context).size.shortestSide * 0.099, height: MediaQuery.of(context).size.shortestSide * 0.102),
                onPressed: () {
                  setState(() {
                    Provider.of<PrizoState>(context, listen: false).isDirty = true;
                    _showButton = false;
                    int tick;
                    if (_showButton){
                    tick = 0;
                    } else { tick = 1;}
                  widget.onUpdate(_counter, producto,tick);
                  });
                }
            )
                : IconButton(
                padding: EdgeInsets.zero,
                icon: Image.asset('assets/icons/checked_checkbox.png', width: MediaQuery.of(context).size.shortestSide * 0.099, height: MediaQuery.of(context).size.shortestSide * 0.102),
                onPressed: () {
                  setState(() {
                  widget.producto = (widget.producto.$1, widget.producto.$2, widget.producto.$3);
                    Provider.of<PrizoState>(context, listen: false).isDirty = true;
                    _showButton = true;
                    int tick;
                    if (_showButton){
                    tick = 0;
                    } else { tick = 1;}
                    widget.onUpdate(_counter, producto,tick);
                  });
                }
            ),
            SizedBox(height: MediaQuery.of(context).size.longestSide * 0.01),
            Container(
              height: MediaQuery.of(context).size.longestSide * 0.0473,
              width: MediaQuery.of(context).size.shortestSide * 0.21,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: MediaQuery.of(context).size.shortestSide * 0.095,
                    child: IconButton(
                      iconSize: MediaQuery.of(context).size.shortestSide * 0.06,
                      padding: EdgeInsets.zero,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(Icons.remove, color: Color.fromARGB(255, 18, 18, 18),),
                      onPressed: () {
                        setState(() {
                          if (_counter > 1) {
                            _counter--;
                            int tick;
                            if (_showButton){
                            tick = 0;
                            } else { tick = 1;}

                            widget.onUpdate(_counter, producto, tick);
                            Provider.of<PrizoState>(context, listen: false).isDirty = true;
                          }
                        });
                      },
                    ),
                  ),
                  Positioned(
                    left: (MediaQuery.of(context).size.shortestSide * 0.238 -
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
                    child: Text(
                      '$_counter',
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
                      left: MediaQuery.of(context).size.shortestSide * 0.125,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                          icon: Icon(Icons.add, size: MediaQuery.of(context).size.shortestSide * 0.06, color: Color.fromARGB(255, 18, 18, 18),),
                        onPressed: () {
                          if (_counter < 99) {
                            setState(() {
                              _counter++;
                              int tick;
                              if (_showButton){
                              tick = 0;
                              } else { tick = 1;}

                              widget.onUpdate(_counter, producto, tick);
                            Provider.of<PrizoState>(context, listen: false).isDirty = true;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
