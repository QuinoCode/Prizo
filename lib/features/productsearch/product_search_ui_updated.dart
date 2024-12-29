import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import '../../../shared/data_entities/models/producto.dart';
import '../../shared/data_entities/models/lista_compra.dart';

import 'package:customizable_counter/customizable_counter.dart';

import '../../features/obtencion_producto/application/carrefour_finder_service.dart';
import '../../features/obtencion_producto/application/consum_finder_service.dart';
import '../../features/obtencion_producto/application/dia_finder_service.dart';

import '../../features/comparacion_productos/application/comparacion_producto.dart';
import '../../features/pantalla_producto/presentation/pantalla_producto_interfaz.dart';

import '../../features/lista_compra/presentation/lista_compra_interfaz.dart';
import '../../features/lista_compra/application/lista_compra_service.dart';
import '../../features/lista_favoritos/presentation/lista_favoritos_interfaz.dart';
import '../lista_favoritos/application/lista_favoritos_service.dart';

import '../../features/escaner/presentation/interfaz_scanner.dart';

//to be made into a list fetched from db
var recentElementA = 'Queso';
var recentElementB = 'Tomate';
var recentElementC = 'Plátanos'; 
var recentElementD = 'Macarrones';
var recentElementE = 'Azúcar';

abstract class ProductSearcher {
  Future<List<List<Producto>>> searchProducts(String query);
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

  @override
  Future<List<List<Producto>>> searchProducts(String query) async {
    try {
      final consumProductsFuture = consumService.getProductList(query);
      final diaProductsFuture = diaService.getProductList(query);
      final carrefourProductsFuture = carrefourService.getProductList(query);
      final results = await Future.wait([consumProductsFuture, diaProductsFuture, carrefourProductsFuture]);
      return results; // Devuelve listas de productos separadas por supermercado
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

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final ConsumFinderService consumService = ConsumFinderService();
  final DiaFinderService diaService = DiaFinderService();
  final CarrefourFinderService carrefourService = CarrefourFinderService();
  final TextEditingController _searchController = TextEditingController();
  List<Producto> _productos = [];
  List<Producto> _productosRestantes = [];
  bool _isLoading = false;
  bool _isSearching = false;
  
  //replace with a list of recents from db
  List<String> values = ['Queso','Tomate','Plátanos','Macarrones','Azúcar'];
  List<bool> _toggled = [true, false, true, false, true];

  final ListaCompraService listaCompraService = ListaCompraService();
  ListaCompra listaCompra = ListaCompra(
      id: '1', usuario: 'usuario_demo', productos: []);
  ListaFavoritos listaFavoritos = ListaFavoritos(
      id: '1', usuario: 'usuario_demo', productos: []);

  @override
  void dispose() {
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

  void _navigateToScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ScannerInterface(),
      ),
    );
  }

  void _navigateToListaCompra() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ListaCompraInterfaz(
              listaCompra: listaCompra,
            ),
      ),
    );
  }

  void _navigateToFilters() {
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
          ScannerInterface(),
      ),
    );*/
  }

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
      final productos = await searcher.searchProducts(_searchController.text);

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

  Widget _buildRecents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        const Text(
          'Recientes',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 8,
          runSpacing: 2,
          children: [
            ElevatedButton(
              onPressed: () => {_searchController.text = recentElementA, _searchProducts()},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical:10),
                foregroundColor: Color.fromARGB(255,80,79,79),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                  side: BorderSide(color: Color.fromARGB(255,174,178,189),)
                ),
              ),
              child: Text(recentElementA),
            ),
            ElevatedButton(
              onPressed: () => {_searchController.text = recentElementB, _searchProducts()},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical:10),
                foregroundColor: Color.fromARGB(255,80,79,79),
                backgroundColor: Color.fromARGB(255,149,179,252),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                  side: BorderSide(color: Color.fromARGB(255,174,178,189),)
                ),
              ),
              child: Text(recentElementB),
            ),
            ElevatedButton(
              onPressed: () => {_searchController.text = recentElementC, _searchProducts()},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical:10),
                foregroundColor: Color.fromARGB(255,80,79,79),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                  side: BorderSide(color: Color.fromARGB(255,174,178,189),)
                ),
              ),
              child: Text(recentElementC),
            ),
            ElevatedButton(
              onPressed: () => {_searchController.text = recentElementD, _searchProducts()},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical:10),
                foregroundColor: Color.fromARGB(255,80,79,79),
                backgroundColor: Color.fromARGB(255,149,179,252),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                  side: BorderSide(color: Color.fromARGB(255,174,178,189),)
                ),
              ),
              child: Text(recentElementD),
            ),
            ElevatedButton(
              onPressed: () => {_searchController.text = recentElementE, _searchProducts()},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical:10),
                foregroundColor: Color.fromARGB(255,80,79,79),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                  side: BorderSide(color: Color.fromARGB(255,174,178,189),)
                ),
              ),
              child: Text(recentElementE),
            ),
          ],
        ),
      ]
    );
  }
  
  Widget _buildSearchResults() {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row of buttons
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _searchController.text = recentElementA;
                _searchProducts();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                foregroundColor: Color.fromARGB(255,80,79,79),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                  side: const BorderSide(color: Color.fromARGB(255, 174, 178, 189)),
                ),
              ),
              child: const Text("Día"),
            ),
            ElevatedButton(
              onPressed: () {
                _searchController.text = recentElementB;
                _searchProducts();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                foregroundColor: Color.fromARGB(255,80,79,79),
                backgroundColor: const Color.fromARGB(255, 149, 179, 252),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                  side: const BorderSide(color: Color.fromARGB(255, 174, 178, 189)),
                ),
              ),
              child: const Text("Carrefour"),
            ),
            ElevatedButton(
              onPressed: () {
                _searchController.text = recentElementC;
                _searchProducts();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                foregroundColor: Color.fromARGB(255,80,79,79),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                  side: const BorderSide(color: Color.fromARGB(255, 174, 178, 189)),
                ),
              ),
              child: const Text("Consum"),
            ),
          ],
        ),
        const SizedBox(height: 10), // Add some spacing
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
                    return _buildProductTile(producto);
                  },
                ),
                // Display the second list if there are remaining products
                if (_productosRestantes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Quizás estabas buscando...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _productosRestantes.length,
                    itemBuilder: (context, index) {
                      final producto = _productosRestantes[index];
                      return _buildProductTile(producto);
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

  //todo formatting
  /*Widget _buildProductTile(Producto producto) {
    final imageUrl = producto.foto;
    final precioMedida = producto.precioMedida > 0 ? ' (${producto.precioMedida.toStringAsFixed(2)}€/kg)' : '';
    return ListTile(
      title: Text(producto.nombre),
      subtitle: Text('${producto.tienda}'),

      
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
      // Al pulsar producto, se abre la pantalla de este
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetallesProducto(
              producto: producto, // El producto seleccionado
              listaCompra: listaCompra, // Pasamos la instancia de ListaCompra
              listaFavoritos: listaFavoritos,
            ),
          ),
        );
      },
    );
  }*/


  Widget _buildProductTile (Producto producto) {
    final imageUrl = producto.foto;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal:5),
              child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.scaleDown
              ),
            ),
            SizedBox(
              height: 90,
              child: VerticalDivider(
                thickness: 1,
                color: Color.fromARGB(255,175,198,255),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width:120,
                    child:
                      Text(
                        producto.nombre,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                              fontFamily: 'Inter',
                              color: Color.fromARGB(255,33,33,33),
                              fontSize: 16,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                      )
                  ),
                  SizedBox(height:3),
                  Text(
                    producto.tienda,
                    style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color.fromARGB(255,33,33,33),
                          fontSize: 12,
                          letterSpacing: 0.0,
                        ),
                  ),
                  SizedBox(height:5),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        '${producto.precio.toString()}€',
                        style: TextStyle(
                              fontFamily: 'Inter',
                              color: Color.fromARGB(255,33,33,33),
                              fontSize: 15,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '${producto.precioMedida.toString()}€/kilo',
                        style: TextStyle(
                              fontFamily: 'Inter',
                              color: Color.fromARGB(255,33,33,33),
                              fontSize: 14,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ]
                  ),
                ],
              ),
            ),
            Spacer(),
            SizedBox(
              width:80,
              child:
                CustomizableCounter(
                  borderWidth: 0,
                  borderRadius: 23,
                  backgroundColor: Color.fromARGB(255, 240, 240, 240),
                  buttonText: 'Añadir',
                  textColor: Colors.black,
                  textSize: 11,
                  count: listaCompraService.getCantidadProducto(listaCompra, producto).toDouble(),
                  minCount: 0,
                  maxCount: 20,
                  onCountChange: (value) {
                    listaCompraService.setCantidadProducto(listaCompra, producto, value.toInt());
                  },
                  step: 1,
                )
            )
          ],
        ),
        SizedBox(height:30)
      ]
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          textAlignVertical: TextAlignVertical(y: 1),
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: ' ',
                            filled: true,
                            fillColor: const Color.fromARGB(255, 240, 240, 240), 
                            prefixIcon: BackButton(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.crop_free),
                              onPressed: _navigateToScanner,
                            ),
                            
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (query) {
                            _searchProducts(); // Llamamos a la función de búsqueda al presionar "Enter"
                          },
                        )
                      )
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width:48,
                    height:40,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255,145,176,243),
                      borderRadius: BorderRadius.circular(20),
                      shape: BoxShape.rectangle
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () => _navigateToFilters(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), 
              _isSearching
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
