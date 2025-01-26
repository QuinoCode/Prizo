import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/database/database_operations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/features/lista/lista.dart';

Database db = DatabaseOperations.instance.prizoDatabase;

class ListaCompraInterfaz extends StatefulWidget {
  final ListaCompra listaCompra;

  ListaCompraInterfaz({super.key, required this.listaCompra});

  @override
  _ListaCompraInterfazState createState() => _ListaCompraInterfazState();
}

class _ListaCompraInterfazState extends State<ListaCompraInterfaz> with WidgetsBindingObserver  {
  List<String> tiendasSeleccionadas = [];
  List<Producto> _productos = [];

  void fetchAndStoreProductos(Database db, ) {
    DatabaseOperations.instance.fetchProductsListaCompra(db).then((result) {
      setState(() {
        _productos = result;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAndStoreProductos(db);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchAndStoreProductos(db); // Force refresh when returning to the UI
    }
  }

  void applyFilter() {
    if (tiendasSeleccionadas.isEmpty) {
      fetchAndStoreProductos(db); // Show all products when no filters are applied.
    } else {
      setState(() {
        _productos = _productos
            .where((producto) => tiendasSeleccionadas.contains(producto.tienda))
            .toList();
      });
    }
  }

  /*void _manejadorTextField(String input) {
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
  }*/

  void _toggleTienda(String tienda) {
    setState(() {
      if (tiendasSeleccionadas.contains(tienda)) {
        tiendasSeleccionadas.remove(tienda);
      } else {
        tiendasSeleccionadas.add(tienda);
      }
    });
    applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading:
        IconButton(
          padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.057,0,0,0),
          icon: ImageIcon(AssetImage('assets/icons/arrow.png')),
          color: Color.fromARGB(255,18,18,18),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListaInterfaz(), // Redirige a lista.dart
              ),
            );
          },
        ),
        title: Text('Lista de compra'),
        centerTitle: true,
        toolbarHeight: MediaQuery.of(context).size.height * 0.092,
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Color.fromARGB(255,18,18,18), fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.width * 0.059, fontWeight: FontWeight.w600),
      ),
      body: SafeArea(
        child: Padding(
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
                      height: MediaQuery.of(context).size.height * 0.0379,
                      width: MediaQuery.of(context).size.width * 0.169,
                      child: ElevatedButton(
                        onPressed: () => _toggleTienda("DIA"),
                        style: ElevatedButton.styleFrom(
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          backgroundColor: tiendasSeleccionadas.contains("DIA") ? Color(0xFF95B3FF) : Colors.white,
                          foregroundColor: Color.fromARGB(255,80,79,79),
                          side: BorderSide(color: Color.fromARGB(255,149,179,255),width: 2),
                        ),
                        child: Text(
                            'Día',
                            style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.width * 0.04, fontWeight: FontWeight.w400)
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.0379,
                      width: MediaQuery.of(context).size.width * 0.274,
                      child: ElevatedButton(
                        onPressed: () => _toggleTienda("CONSUM"),
                        style: ElevatedButton.styleFrom(
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          backgroundColor: tiendasSeleccionadas.contains("CONSUM") ? Color(0xFF95B3FF) : Colors.white,
                          foregroundColor: Color.fromARGB(255,80,79,79),
                          side: BorderSide(color: Color(0xFF95B3FF),width: 2),
                        ),
                        child: Text(
                            'Consum',
                            style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.width * 0.04, fontWeight: FontWeight.w400)
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.0379,
                      width: MediaQuery.of(context).size.width * 0.305,
                      child: ElevatedButton(
                        onPressed: () => _toggleTienda("Carrefour"),
                        style: ElevatedButton.styleFrom(
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          backgroundColor: tiendasSeleccionadas.contains("Carrefour") ? Color(0xFF95B3FF) : Colors.white,
                          foregroundColor: Color.fromARGB(255,80,79,79),
                          side: BorderSide(color: Color(0xFF95B3FF),width: 2),
                        ),
                        child: Text(
                            'Carrefour',
                            style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.width * 0.04, fontWeight: FontWeight.w400)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.018),
              // Scrollable list
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display the first list of products
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _productos.length,
                              itemBuilder: (context, index) {
                                final producto = _productos[index];
                                return StatefulStoreItem(producto: producto, onAction: () => fetchAndStoreProductos(db));
                              },
                            ),
                          ]
                      )
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}

class StatefulStoreItem extends StatefulWidget {
  final Producto producto;
  final VoidCallback onAction;
  const StatefulStoreItem({required this.producto, required this.onAction});

  @override
  _ProductTileItemState createState() => _ProductTileItemState();
}

class _ProductTileItemState extends State<StatefulStoreItem> {
  ListaCompraService listaCompraService = ListaCompraService();
  bool _showButton = true;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _cargarContador();
    _cargarBoton();
  }

  String shortenText(String nombre){
    if(nombre.length >= 18){
      return nombre.substring(0,18) +'...';
    } else {
      return nombre;
    }
  }

  Future<void> _cargarContador () async {
    int count = await DatabaseOperations.instance.fetchCantidadListaCompra(db, widget.producto);
    setState(() {
      _counter = count;
    });
  }
  Future<void> _cargarBoton () async {
    bool boton = await listaCompraService.DB_Tick_tiene_tick(widget.producto);
    setState(() {
      _showButton = !boton;
    });
  }

  Future<void> _ventanaConfirmacion(BuildContext context, Producto producto) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, /* Evita cerrar el diálogo tocando fuera de él */
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Eliminar producto?'),
          content: Text('¿Estás seguro de que deseas eliminar el producto ${producto.nombre}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                _counter = await DatabaseOperations.instance.fetchCantidadListaCompra(db, producto);
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                /* Eliminar el producto completo de la lista */
                //DatabaseOperations.instance.deleteFromListaCompraTable(db, producto);
                listaCompraService.DB_quitarProducto(producto);
                widget.onAction();
                Navigator.of(context).pop(); /* Cerrar el cuadro de diálogo */
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
            child: Row(
              children: [
                Image.network(
                  widget.producto.foto,
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.width * 0.2,
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.019),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: VerticalDivider(
                    thickness: 1,
                    color: Color.fromARGB(255,175,198,255),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                Expanded(
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.283,
                          child:
                          Text(
                            shortenText(widget.producto.nombre),
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
                      SizedBox(height: MediaQuery.of(context).size.height * 0.001),
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
                      Text(
                        '${widget.producto.precio}€',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          color: Color.fromARGB(255,33,33,33),
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width * 0.023),
                    ],
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.053),
                Padding(
                  padding: EdgeInsets.fromLTRB(10,0,0,16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _showButton
                          ? IconButton(
                          padding: EdgeInsets.all(0),
                          icon: Image.asset('assets/icons/empty_checkbox.png', width: MediaQuery.of(context).size.width * 0.099, height: MediaQuery.of(context).size.width * 0.102),
                          onPressed: () {
                            setState(() {
                              _showButton = false;
                            });
                            listaCompraService.DB_Tick_annadir(widget.producto);
                          }
                      )
                          : IconButton(
                          padding: EdgeInsets.all(0),
                          icon: Image.asset('assets/icons/checked_checkbox.png', width: MediaQuery.of(context).size.width * 0.099, height: MediaQuery.of(context).size.width * 0.102),
                          onPressed: () {
                            setState(() {
                              _showButton = true;
                            });
                            listaCompraService.DB_Tick_quitar(widget.producto);
                          }
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.0473,
                        width: MediaQuery.of(context).size.width * 0.21,
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
                              right: MediaQuery.of(context).size.width * 0.085,
                              child: IconButton(
                                iconSize: MediaQuery.of(context).size.width * 0.06,
                                padding: EdgeInsets.zero,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (_counter > 1) {
                                      //DatabaseOperations.instance.decreaseCantidadListaCompra(db, widget.producto);
                                      listaCompraService.DB_decreaseCantidad(widget.producto);
                                      _counter--;
                                    } else {
                                      _ventanaConfirmacion(context, widget.producto);
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
                              left: MediaQuery.of(context).size.width * 0.105,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                icon: Icon(Icons.add, size: MediaQuery.of(context).size.width * 0.06),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]
    );
  }
}