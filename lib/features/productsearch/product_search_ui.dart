import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:sqflite/sqflite.dart';
import 'package:prizo/shared/database/database_operations.dart';

import '../../../shared/data_entities/models/producto.dart';
import '../../shared/data_entities/models/lista_compra.dart';

import '../../features/obtencion_producto/application/carrefour_finder_service.dart';
import '../../features/obtencion_producto/application/consum_finder_service.dart';
import '../../features/obtencion_producto/application/dia_finder_service.dart';

import '../../features/comparacion_productos/application/comparacion_producto.dart';

import '../../features/lista_compra/application/lista_compra_service.dart';
import '../../features/filtro_busqueda/filtro_busqueda.dart';

import '../../features/pantalla_producto/presentation/pantalla_producto_interfaz.dart';

import '../../features/escaner/presentation/interfaz_scanner.dart' as scanner;

final ListaCompraService listaCompraService = ListaCompraService();
ListaCompra listaCompra = ListaCompra(
    id: '1', usuario: 'usuario_demo', productos: []);
ListaFavoritos listaFavoritos = ListaFavoritos(
    id: '1', usuario: 'usuario_demo', productos: []);


abstract class ProductSearcher {
  Future<List<List<Producto>>> searchProducts(String query, List<String> stores);
}

class MultiMarketProductSearcher implements ProductSearcher {
  final ConsumFinderService consumService;
  final DiaFinderService diaService;
  final CarrefourFinderService carrefourService;

  MultiMarketProductSearcher({
    required this.consumService,
    required this.diaService,
    required this.carrefourService,
  });

  //make the get products list use stores for a return, remove override
  @override
  Future<List<List<Producto>>> searchProducts(String query, List<String> stores) async {
    try {
      // Default to all stores if none are selected
      if (stores.isEmpty) {
        stores = ["Consum", "Dia", "Carrefour"];
      }

      // Initialize all futures
      final consumProductsFuture = consumService.getProductList(query);
      final diaProductsFuture = diaService.getProductList(query);
      final carrefourProductsFuture = carrefourService.getProductList(query);

      // Selectively await the futures based on the stores
      List<List<Producto>> results = [];
      if (stores.contains("Consum")) {
        results.add(await consumProductsFuture);
      }
      if (stores.contains("Dia")) {
        results.add(await diaProductsFuture);
      }
      if (stores.contains("Carrefour")) {
        results.add(await carrefourProductsFuture);
      }

      return results; // Return only the results for the selected stores
    } catch (e) {
      print("Error al buscar productos: $e");
      return [];
    }
  }
}


String shortenText(String nombre, int limit, String replacement){
  if(nombre.length > limit){
    return nombre.substring(0,limit) +replacement;
  } else {
    return nombre;
  }
}

class ProductSearchScreenU extends StatelessWidget {
  const ProductSearchScreenU ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const ProductSearchScreen(),
    );
  }
}

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> with SingleTickerProviderStateMixin{
  final ConsumFinderService consumService = ConsumFinderService();
  final DiaFinderService diaService = DiaFinderService();
  final CarrefourFinderService carrefourService = CarrefourFinderService();
  final TextEditingController _searchController = TextEditingController();
  List<Producto> _productos = [];
  List<bool> _isPressed = [false,false,false,false,false];
  List<Producto> _productosRestantes = [];
  List<String> tiendasSeleccionadas = [];
  List<int> alergenosSeleccionados = [];
  bool _isLoading = false;
  bool _isSearching = false;
  final List<String> recentElements = [
    '',
    '',
    '',
    '',
    ''
  ];

  final List<ValueNotifier<Color>> _colorNotifiers = List.generate(
    5,  // Assuming you have 5 buttons
    (_) => ValueNotifier(Colors.white),
  );

  @override
  void dispose() {
    _searchController.dispose();
    for (var notifier in _colorNotifiers) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Add a listener to check when the text becomes empty
    _searchController.addListener(() {
      if (_searchController.text.isEmpty && _isSearching) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  void _toggleTienda(String tienda) {
    setState(() {
      if (tiendasSeleccionadas.contains(tienda)) {
        tiendasSeleccionadas.remove(tienda);
      } else {
        tiendasSeleccionadas.add(tienda);
      }
    });
    _searchProducts();
  }

  //cambios de pantalla
  void _navigateToScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const scanner.ScannerInterface(),
      ),
    );
  }

  // Solo se aplica el filtrado por alergenos
  void _navigateToFilters() async {
    final updatedAlergenos = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FiltroProductosInterfaz(alergenos: alergenosSeleccionados),
      ),
    );

    if (updatedAlergenos != null) {
      setState(() {
        alergenosSeleccionados = updatedAlergenos;
      });
      _searchProducts();
    }
  }

  List<List<Producto>> filtrar_alergeno(List<List<Producto>> productos) {
    if (productos.isEmpty) { return productos; }
    if (alergenosSeleccionados.isEmpty) { return productos; }
    List<List<Producto>> productosFiltrados = [];
    for (List<Producto> lista in productos) {
      List<Producto> listaAuxiliar = [];
      for (Producto producto in lista) {
        if(!tieneAlergeno(producto)) {
          listaAuxiliar.add(producto);
        }
      }
      productosFiltrados.add(listaAuxiliar);
    }
    return productosFiltrados;
  }

  bool tieneAlergeno(Producto producto) {
    for (int indice in alergenosSeleccionados) {
      if (!(indice < 0 || indice >= producto.alergenos.length) && producto.alergenos[indice]) {
        return true;
      }
    }
    return false;
  }

  //Llamar a búsqueda
  void _searchProducts() async {
    setState(() {
      _isLoading = true;
      _isSearching = true;
    });

    final searcher = MultiMarketProductSearcher(
      consumService: consumService,
      diaService: diaService,
      carrefourService: carrefourService,
    );

    try {
      final productos = await searcher.searchProducts(_searchController.text, tiendasSeleccionadas);
      List<List<Producto>> filtrado_por_alergeno = filtrar_alergeno(productos);

      // Por cada súper separa los productos en dos listas
      List<(List<Producto>, List<Producto>)> listasSeparadas = filtrado_por_alergeno.map((productosSuper) => ordenaPrioridadCategoria(productosSuper)).toList();

      // Combina las primeras listas de cada supermercado y las segundas de cada supermercado entre ellas
      final (List<Producto> listaCategoria, List<Producto> listaRestante) = combinaListasSupers(listasSeparadas);
      setState(() {
        _productos = listaCategoria;
        _productosRestantes = listaRestante;
      });
      if (filtrado_por_alergeno.isEmpty) {
        print("No se encontraron productos para la consulta: ${_searchController.text}");
      }
    } catch (e) {
      print("Error al buscar productos: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
      if (_searchController.text.isEmpty){
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Widget _buildRecents() {
    Database db = DatabaseOperations.instance.prizoDatabase;
    return FutureBuilder<List<Map<String, Object?>>>(
      future: DatabaseOperations.instance.fetchItemsListaRecientes(db),
      builder: (context, snapshot) {
        // Check if the future has completed
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.hasData) {
          // Extract the result from snapshot
          var result = snapshot.data!;

          // Ensure the list has 5 elements
          recentElements[0] = result.length > 0 ? result[0]['busqueda'].toString() : 'Queso';
          recentElements[1] = result.length > 1 ? result[1]['busqueda'].toString() : 'Tomate';
          recentElements[2] = result.length > 2 ? result[2]['busqueda'].toString() : 'Plátanos';
          recentElements[3] = result.length > 3 ? result[3]['busqueda'].toString() : 'Macarrones';
          recentElements[4] = result.length > 4 ? result[4]['busqueda'].toString() : 'Azúcar';

          // Build the UI with the fetched data
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recientes',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: MediaQuery.of(context).size.width * 0.092,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.113,
                width: MediaQuery.of(context).size.width * 0.802,
                child: Wrap(
                  spacing: MediaQuery.of(context).size.width * 0.0333,
                  runSpacing: MediaQuery.of(context).size.height * 0.009,
                  children: List.generate(recentElements.length, (index) {
                    return GestureDetector(
                      onPanStart: (_) {
                        _colorNotifiers[index].value = Color.fromARGB(255, 149, 179, 252);  // Highlight color on pan start
                      },
                      onPanEnd: (_) {
                        _colorNotifiers[index].value = Colors.white;  // Reset color on pan end
                      },
                      child: ValueListenableBuilder<Color>(
                        valueListenable: _colorNotifiers[index],
                        builder: (context, color, child) {
                          return ElevatedButton(
                            onPressed: () {
                              _searchController.text = recentElements[index];
                              _searchProducts();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.048,
                                vertical: MediaQuery.of(context).size.height * 0.012,
                              ),
                              textStyle: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.width * 0.04, fontWeight: FontWeight.w400, color: Color.fromARGB(255,18,18,18)),
                              shadowColor: Colors.transparent,
                              foregroundColor: Color.fromARGB(255, 80, 79, 79),
                              backgroundColor: color, // Dynamically change the background color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(23),
                                side: BorderSide(color: Color.fromARGB(255, 149, 179, 255)),
                              ),
                            ),
                            child: Text(shortenText(recentElements[index],6,'..')),
                          );
                        },
                      ),
                    );
                  }),
                )
              ),
            ],
          );
        }
        // Default case: no data available
        return Center(child: Text('No recent items available')
        );

      },
    );
  }
  
  Widget _buildSearchResults() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.0079), 
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.0379,
                width: MediaQuery.of(context).size.width * 0.169,
                child: ElevatedButton(
                  onPressed: () => _toggleTienda("Dia"),
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    backgroundColor: tiendasSeleccionadas.contains("Dia") ? Color(0xFF95B3FF) : Colors.white,
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
                  onPressed: () => _toggleTienda("Consum"),
                  style: ElevatedButton.styleFrom(
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      backgroundColor: tiendasSeleccionadas.contains("Consum") ? Color(0xFF95B3FF) : Colors.white,
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.0379),
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
                      return _buildProductTile(context, producto);
                    },
                  ),
                  // Display the second list if there are remaining products
                  if (_productosRestantes.isNotEmpty) ...[
                    SizedBox(height: MediaQuery.of(context).size.height * 0.026),
                    Text(
                      'Quizás estabas buscando...',
                      style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.width * 0.05, fontWeight: FontWeight.bold),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _productosRestantes.length,
                      itemBuilder: (context, index) {
                        final producto = _productosRestantes[index];
                        return _buildProductTile(context, producto);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, Producto producto) {
    Database db = DatabaseOperations.instance.prizoDatabase;
    return StatefulStoreItem(producto: producto, database: db);
  }

  @override
  Widget build(BuildContext context) {
    Database db = DatabaseOperations.instance.prizoDatabase;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,  
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(18,16,16,16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.017),
              Row(
                children: [
                  Expanded(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0521,
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.width * 0.03846, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            hintText: ' ',
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 246, 246, 246), 
                            prefixIcon: IconButton(
                              padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.057,0,MediaQuery.of(context).size.width*0.0206,0),
                              icon: ImageIcon(AssetImage('assets/icons/arrow.png')),
                              color: Color.fromARGB(255,18,18,18),
                              onPressed: () {},
                            ),
                            suffixIcon: IconButton(
                              iconSize: MediaQuery.of(context).size.width * 0.0615,
                              icon: ImageIcon(AssetImage('assets/icons/scanner.png'), ),
                              color: Color.fromARGB(255,18,18,18),
                              onPressed: _navigateToScanner,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (query) {
                            if (_searchController.text != ""){
                              DatabaseOperations.instance.registerReciente(db, query);
                            }
                            _searchProducts(); // Llamamos a la función de búsqueda al presionar "Enter"
                          },
                        )
                      )
                  ),
                  SizedBox(width: MediaQuery.of(context).size.height * 0.017),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.1410,
                    height: MediaQuery.of(context).size.height * 0.0521,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255,145,176,243),
                      borderRadius: BorderRadius.circular(20),
                      shape: BoxShape.rectangle
                    ),
                    child: IconButton(
                      iconSize: MediaQuery.of(context).size.width * 0.0615,
                      icon: ImageIcon(AssetImage('assets/icons/filter.png'),color: Color.fromARGB(255,18,18,18),),
                      onPressed: () => _navigateToFilters(), // Botón de filtros
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03), 
              _isSearching //Decide si mostrar recientes o si mostrar resultados de busqueda
                ? _isLoading
                  ? const Center( heightFactor: 12, child: CircularProgressIndicator(), )
                  : _buildSearchResults()
                : _buildRecents(),
              
            ],
          ),
        ),
      ),
    );
  }
}

//Declaración de un nuevo statefulWidget para instanciar los elementos de producto, falta que el contador tome de la lista de compra
class StatefulStoreItem extends StatefulWidget {
  final Producto producto;
  final Database database;
  const StatefulStoreItem({required this.producto, required this.database});

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
                                  color: Color.fromARGB(255,33,33,33),
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
                          DatabaseOperations.instance.existsInListaCompraTable(widget.database, widget.producto).then((exists) {
                            if (exists) {
                              DatabaseOperations.instance.fetchCantidadListaCompra(widget.database, widget.producto).then((cantidad) {
                                setState(() {
                                  _counter = cantidad;  // Set _counter to the fetched cantidad
                                  _showButton = false; // Update _showButton only if the product exists in the table
                                });
                              });
                            } else {
                              //DatabaseOperations.instance.registerIntoProductTable(widget.database, widget.producto).then((_) {});
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
                            right: MediaQuery.of(context).size.width * 0.095,
                            child: IconButton(
                              iconSize: MediaQuery.of(context).size.width * 0.06,
                              padding: EdgeInsets.zero,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,  
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (_counter > 0) {
                                    if(_counter == 1) {
                                      listaCompraService.DB_quitarProducto(widget.producto);
                                      listaCompraService.DB_Tick_quitar(widget.producto);
                                    } else {
                                      listaCompraService.DB_decreaseCantidad(widget.producto);
                                    }
                                    //listaCompraService.DB_decreaseCantidad(widget.producto);
                                    //DatabaseOperations.instance.decreaseCantidadListaCompra(widget.database, widget.producto);
                                    _counter--;
                                  } else {
                                    listaCompraService.DB_quitarProducto(widget.producto);
                                    listaCompraService.DB_Tick_quitar(widget.producto);
                                    //DatabaseOperations.instance.deleteFromListaCompraTable(widget.database, widget.producto);
                                    _showButton = true;
                                  }
                                });
                              },
                            ),
                          ),
                          _counter < 10 
                          ? Positioned(
                              left: MediaQuery.of(context).size.width * 0.089,
                              top: MediaQuery.of(context).size.height * 0.004,
                              bottom: 0,
                              child: Text('$_counter', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.0615, fontWeight: FontWeight.w400)),
                            )
                          : Positioned(
                              left: MediaQuery.of(context).size.width * 0.074,
                              top: MediaQuery.of(context).size.height * 0.006,
                              bottom: 0,
                              child: Text('$_counter', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.0538, fontWeight: FontWeight.w400)),
                            ),
                          Positioned(
                            top: 0,
                            bottom: MediaQuery.of(context).size.height * 0.001,
                            left: MediaQuery.of(context).size.width * 0.093,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,  
                              icon: Icon(Icons.add, size: MediaQuery.of(context).size.width * 0.06),
                              onPressed: () {
                                if (_counter < 99) {
                                  listaCompraService.DB_annadirProducto(widget.producto);
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
                )
            ],
          ),
        ),
      ]
    );
  }
}