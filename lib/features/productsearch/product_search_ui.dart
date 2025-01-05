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

import '../../features/lista_compra/presentation/lista_compra_interfaz.dart';
import '../../features/lista_compra/application/lista_compra_service.dart';
import '../../features/filtro_busqueda/filtro_busqueda.dart';

import '../../features/pantalla_producto/presentation/pantalla_producto_interfaz.dart';

import '../../features/escaner/presentation/interfaz_scanner.dart' as scanner;

final ListaCompraService listaCompraService = ListaCompraService();
ListaCompra listaCompra = ListaCompra(
    id: '1', usuario: 'usuario_demo', productos: []);
ListaFavoritos listaFavoritos = ListaFavoritos(
    id: '1', usuario: 'usuario_demo', productos: []);
Database db = DatabaseOperations.instance.prizoDatabase;

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
  late TabController _tabController;
  List<Producto> _productos = [];
  List<Producto> _productosRestantes = [];
  List<String> tiendasSeleccionadas = [];
  bool _isLoading = false;
  bool _isSearching = false;
  var recentElementA, recentElementB, recentElementC, recentElementD, recentElementE;

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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

  void _navigateToListaCompra() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ListaCompraInterfaz(
              listaCompra: listaCompra, original: listaCompra,
            ),
      ),
    );
  }

  //falta navegar a filtros
  void _navigateToFilters() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FiltroProductosInterfaz(
              alergenos: [],
            ),
      ),
    );
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

      // Por cada súper separa los productos en dos listas
      List<(List<Producto>, List<Producto>)> listasSeparadas = productos.map((productosSuper) => ordenaPrioridadCategoria(productosSuper)).toList();

      // Combina las primeras listas de cada supermercado y las segundas de cada supermercado entre ellas
      final (List<Producto> listaCategoria, List<Producto> listaRestante) = combinaListasSupers(listasSeparadas);
      setState(() {
        _productos = listaCategoria;
        _productosRestantes = listaRestante;
      });
      if (productos.isEmpty) {
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

  //Construye pantalla de recientes, faltan recientes 
  Widget _buildRecents() {
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
          String recentElementA = result.length > 0 ? result[0]['busqueda'].toString() : 'Queso';
          String recentElementB = result.length > 1 ? result[1]['busqueda'].toString() : 'Tomate';
          String recentElementC = result.length > 2 ? result[2]['busqueda'].toString() : 'Plátanos';
          String recentElementD = result.length > 3 ? result[3]['busqueda'].toString() : 'Macarrones';
          String recentElementE = result.length > 4 ? result[4]['busqueda'].toString() : 'Azúcar';

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
              SizedBox(height: MediaQuery.of(context).size.height * 0.017),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.113,
                width: MediaQuery.of(context).size.width * 0.802,
                child: Wrap(
                  spacing: MediaQuery.of(context).size.width * 0.0333,
                  runSpacing: MediaQuery.of(context).size.height * 0.009,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _searchController.text = recentElementA;
                        _searchProducts();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.048, vertical: MediaQuery.of(context).size.height * 0.012,),
                        shadowColor: Colors.transparent,
                        foregroundColor: Color.fromARGB(255, 80, 79, 79),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                          side: BorderSide(color: Color.fromARGB(255,149,179,255)),
                        ),
                      ),
                      child: Text(recentElementA),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _searchController.text = recentElementB;
                        _searchProducts();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.048, vertical: MediaQuery.of(context).size.height * 0.012,),
                        shadowColor: Colors.transparent,
                        foregroundColor: Color.fromARGB(255, 80, 79, 79),
                        backgroundColor: Color.fromARGB(255, 149, 179, 252),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                          side: BorderSide(color: Color.fromARGB(255,149,179,255)),
                        ),
                      ),
                      child: Text(recentElementB),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _searchController.text = recentElementC;
                        _searchProducts();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.048, vertical: MediaQuery.of(context).size.height * 0.012,),
                        shadowColor: Colors.transparent,
                        foregroundColor: Color.fromARGB(255, 80, 79, 79),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                          side: BorderSide(color: Color.fromARGB(255,149,179,255)),
                        ),
                      ),
                      child: Text(recentElementC),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _searchController.text = recentElementD;
                        _searchProducts();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.048, vertical: MediaQuery.of(context).size.height * 0.012,),
                        shadowColor: Colors.transparent,
                        foregroundColor: Color.fromARGB(255, 80, 79, 79),
                        backgroundColor: Color.fromARGB(255, 149, 179, 252),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                          side: BorderSide(color: Color.fromARGB(255,149,179,255)),
                        ),
                      ),
                      child: Text(recentElementD),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _searchController.text = recentElementE;
                        _searchProducts();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.048, vertical: MediaQuery.of(context).size.height * 0.012,),
                        shadowColor: Colors.transparent,
                        foregroundColor: Color.fromARGB(255, 80, 79, 79),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                          side: BorderSide(color: Color.fromARGB(255,149,179,255)),
                        ),
                      ),
                      child: Text(recentElementE),
                    ),
                  ],
                ),
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
    return StatefulStoreItem(producto: producto);
  }

  @override
  Widget build(BuildContext context) {
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
                          textAlignVertical: TextAlignVertical(y: 1),
                          controller: _searchController,
                          style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.width * 0.03846, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            hintText: ' ',
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
      //navigator unused at the moment
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_outlined),
            selectedIcon: Icon(Icons.list),
            label: 'List',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

//Declaración de un nuevo statefulWidget para instanciar los elementos de producto, falta que el contador tome de la lista de compra
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

  String shortenText(String nombre){
    if(nombre.length >= 18){
      return nombre.substring(0,18) +'...';
    } else {
      return nombre;
    }
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
              SizedBox(width: MediaQuery.of(context).size.width * 0.0205), 
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
      ]
    );
  }
}
