import 'package:flutter/material.dart';
import 'package:prizo/features/informacion_producto/pantalla_producto/presentation/pantalla_producto_interfaz.dart';
import 'package:prizo/features/pantry/pantry_logic.dart';
import 'package:prizo/shared/application/producto_service.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/shared/data_entities/models/pantry_list.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/database/database_operations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:provider/provider.dart';
import 'package:prizo/main.dart';

class PantryListInterface extends StatefulWidget {
  PantryListInterface({super.key});

  @override
  _PantryListInterfaceState createState() => _PantryListInterfaceState();
}

class _PantryListInterfaceState extends State<PantryListInterface> with WidgetsBindingObserver  {
  List<String> selectedStores = [];
  List<Producto> _products = [];
  final ProductoService productoService = ProductoService();
  late final PantryLogic pantryService;
  PantryList pantryList = PantryList(id: '1', user: 'usuario_demo', products: []);
  bool _isLoading = true;


  Future<void> fetchAndStoreProductos() async{
    Database db = DatabaseOperations.instance.prizoDatabase;
    var result = await DatabaseOperations.instance.fetchProductsFromPantryList(db);
    setState(() {
      _products = result;
    });
  }

  Future<void> _initPantryList() async{
    PantryList fetchedLista = await pantryService.generatePantryList();
    setState(() {
       pantryList = fetchedLista;
      _isLoading = false;
    });
  }

  @override
  void didUpdateWidget(PantryListInterface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      _initPantryList();  // llamar a init otra vez
    }
  }

  Future<void> _setup() async {
    pantryService = await PantryLogic.instance();
    await fetchAndStoreProductos();
    await _initPantryList();                          // load pantry list
    if (!mounted) return;
    setState(() => _isLoading = false);}


  @override
  void initState()  {
    super.initState();
    _initPantryList();
    fetchAndStoreProductos();
    _setup();
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
      fetchAndStoreProductos(); // Force refresh when returning to the UI
    }
  }

  void applyFilter() {
    if (selectedStores.isEmpty) {
      fetchAndStoreProductos(); // Show all products when no filters are applied.
    } else {
      setState(() {
        _products = _products
            .where((producto) => selectedStores.contains(producto.tienda))
            .toList();
      });
    }
  }

  void _toggleStore(String store) {
    setState(() {
      if (selectedStores.contains(store)) {
        selectedStores.remove(store);
      } else {
        selectedStores.add(store);
      }
    });
    applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.shortestSide*0.057, 0, 0, 0),
          icon: ImageIcon(AssetImage('assets/icons/arrow.png')),
          color: Color.fromARGB(255,18,18,18),
          splashColor: Colors.transparent,
          onPressed: () {
            Provider.of<PrizoState>(context, listen: false).setIndex(2);
          },
        ),
        surfaceTintColor: Colors.transparent,
        title: Text('Despensa'),
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
                    onPressed: () => _toggleStore("DIA"),
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      backgroundColor: selectedStores.contains("DIA") ? Color(0xFF95B3FF) : Colors.white,
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
                    onPressed: () => _toggleStore("CONSUM"),
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      backgroundColor: selectedStores.contains("CONSUM") ? Color(0xFF95B3FF) : Colors.white,
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
                    onPressed: () => _toggleStore("Carrefour"),
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      backgroundColor: selectedStores.contains("Carrefour") ? Color(0xFF95B3FF) : Colors.white,
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
          // Scrollable list
          Expanded(
            child: _isLoading 
            ? Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.longestSide * 0.17),
              child: SizedBox(
                  height: MediaQuery.of(context).size.longestSide * 0.264,
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF95B3FF), ))
                )
            )
            : _products.isEmpty
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
                padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.shortestSide * 0.0550, 0, MediaQuery.of(context).size.shortestSide * 0.0550, MediaQuery.of(context).size.longestSide * 0.1),
                child: ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final producto = _products[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.longestSide * 0.0218),
                      child: Dismissible(
                          key: Key(productoService.generarClave(producto)),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (direction) {
                          setState(() {
                            pantryService.removeProduct(pantryList, producto);
                            pantryService.dbRemoveProductFromPantry(producto);
                            _products.removeAt(index);
                          });
                          },
                          background: Container(
                            //color: Color(0xFF95B3FF),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(color: Color(0xFF95B3FF), borderRadius: BorderRadius.circular(23)),
                              child: ImageIcon(AssetImage('assets/icons/basura.png'), size: MediaQuery.of(context).size.shortestSide * 0.0872)
                          ),
                          child: StatefulStoreItem(producto: producto, onReturn: () => fetchAndStoreProductos())
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
  final Producto producto;
  final VoidCallback onReturn;
  const StatefulStoreItem({super.key, required this.producto, required this.onReturn});

  @override
  _ProductTileItemState createState() => _ProductTileItemState();
}

class _ProductTileItemState extends State<StatefulStoreItem> {
  late final PantryLogic pantryLogic;
  bool _showButton = true;
  int _counter = 0;

  @override
  void initState() async {
    super.initState();
    _cargarContador();
    _cargarBoton();
    pantryLogic  = await PantryLogic.instance();
  }

  @override
  void didUpdateWidget(covariant StatefulStoreItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    //recargar los ticks al borrado
    if (widget.producto != oldWidget.producto) {
      _cargarBoton();
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

  String shortenText(String nombre){
    if(nombre.length >= 18){
      return nombre.substring(0,18) +'...';
    } else {
      return nombre;
    }
  }

  Future<void> _cargarContador () async {
    Database db = DatabaseOperations.instance.prizoDatabase;
    int count = await DatabaseOperations.instance.fetchAmountPantryList(db, widget.producto);
    setState(() {
      _counter = count;
    });
  }

  Future<void> _cargarBoton () async {
    bool boton = await pantryLogic.dbHasTickPantryo(widget.producto);
    setState(() {
      _showButton = !boton;
    });
  }

  Future<void> _ventanaConfirmacion(BuildContext context, Producto producto) async {
    Database db = DatabaseOperations.instance.prizoDatabase;
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
                _counter = await DatabaseOperations.instance.fetchCantidadListaCompra(db, producto);
                Navigator.of(context).pop();
              },
              child: Text('Cancelar',
                  style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.0322, fontWeight: FontWeight.w400)),
            ),
            TextButton(
              onPressed: () {
                /* Eliminar el producto completo de la lista */
                //DatabaseOperations.instance.deleteFromListaCompraTable(db, producto);
                pantryLogic.dbRemoveProductFromPantry(producto);
                pantryLogic.dbTickRemove(producto);
                setState(() {
                  _showButton = false;
                });
                widget.onReturn();
                Navigator.of(context).pop(); /* Cerrar el cuadro de diálogo */
              },
              child: Text('Eliminar',
                  style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.shortestSide * 0.0322, fontWeight: FontWeight.w400)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255,33,33,33),
                    fontSize: MediaQuery.of(context).size.shortestSide * 0.0322,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.shortestSide * 0.023),
                Text(
                  '${(widget.producto.precio * _counter).toStringAsFixed(2)}€',
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
                    _showButton = false;
                  });
                  pantryLogic.dbAddTick(widget.producto);
                }
            )
                : IconButton(
                padding: EdgeInsets.zero,
                icon: Image.asset('assets/icons/checked_checkbox.png', width: MediaQuery.of(context).size.shortestSide * 0.099, height: MediaQuery.of(context).size.shortestSide * 0.102),
                onPressed: () {
                  setState(() {
                    _showButton = true;
                  });
                  pantryLogic.dbTickRemove(widget.producto);
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
                          if (_counter > 0) {
                            if(_counter == 1) {
                              pantryLogic.dbRemoveProductFromPantry(widget.producto);
                              pantryLogic.dbTickRemove(widget.producto);
                            } else {
                              pantryLogic.dbDecreaseProductAmountInPantry(widget.producto);
                            }
                            //listaCompraService.DB_decreaseCantidad(widget.producto);
                            //DatabaseOperations.instance.decreaseCantidadListaCompra(widget.database, widget.producto);
                            _counter--;
                          } else {
                            pantryLogic.dbRemoveProductFromPantry(widget.producto);
                            pantryLogic.dbTickRemove(widget.producto);
                            //DatabaseOperations.instance.deleteFromListaCompraTable(widget.database, widget.producto);
                            _showButton = true;
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
                          pantryLogic.dbAddProduct(widget.producto);
                          //DatabaseOperations.instance.increaseCantidadListaCompra(widget.database, widget.producto);
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
      ],
    );
  }
}
