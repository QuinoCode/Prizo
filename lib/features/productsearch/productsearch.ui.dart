import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/data_entities/producto.dart';
import '../../features/obtencion_producto/application/consum_finder_service.dart';
import '../../features/obtencion_producto/application/dia_finder_service.dart';
import '../../features/comparacion_productos/application/comparacion_producto.dart';
import '../../features/obtencion_producto/application/carrefour_finder_service.dart';
import '../../features/lista_compra/presentation/lista_compra_interfaz.dart';
import '../../../shared/data_entities/lista_compra.dart';
import '../../features/lista_compra/application/lista_compra_service.dart';
import '../../../shared/data_entities/lista_favoritos.dart';
import '../../features/lista_favoritos/presentation/lista_favoritos_interfaz.dart';
import '../../features/productsearch/productsearch_auxiliar.dart';

abstract class ProductSearcher {
  Future<List<Producto>> searchProducts(String query);
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
  Future<List<Producto>> searchProducts(String query) async {
    try {
      final consumProductsFuture = consumService.fetchProductsFromApi(query);
      final diaProductsFuture = diaService.getProductList(query);
      final carrefourProductsFuture = carrefourService.getProductList(query);
      final results = await Future.wait([consumProductsFuture, diaProductsFuture, carrefourProductsFuture]);
      final allProducts = <Producto>[];
      if (results[0] != null) {
        allProducts.addAll(results[0] as List<Producto>);
      }
      if (results[1] != null) {
        allProducts.addAll(results[1] as List<Producto>);
      }
      if (results[2] != null) {
        allProducts.addAll(results[2] as List<Producto>);
      }
      ordenarProductosPorPrecio(allProducts);
      return allProducts;
    } catch (e) {
      print("Error al buscar productos: $e");
      return [];
    }
  }
}

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({Key? key}) : super(key: key);

  @override
  ProductSearchScreenState createState() => ProductSearchScreenState();
}

class ProductSearchScreenState extends State<ProductSearchScreen> {
  final ConsumFinderService consumService = ConsumFinderService();
  final DiaFinderService diaService = DiaFinderService();
  final CarrefourFinderService carrefourService = CarrefourFinderService();
  final TextEditingController _searchController = TextEditingController();
  List<Producto> _productos = [];
  bool _isLoading = false;
  final ListaCompraService listaCompraService = ListaCompraService();
  ListaCompra listaCompra = ListaCompra(id: '1', usuario: 'usuario_demo', productos: []);
  ListaFavoritos listaFavoritos = ListaFavoritos(id: '1', usuario: 'usuario_demo', productos: []);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchProducts() async {
    setState(() {
      _isLoading = true;
    });

    final searcher = MultiMarketProductSearcher(
      consumService: consumService,
      diaService: diaService,
      carrefourService: carrefourService,
    );

    try {
      final productos = await searcher.searchProducts(_searchController.text);
      setState(() {
        _productos = productos;
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
    }
  }

  void _navigateToListaCompra() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaCompraInterfaz(
          listaCompra: listaCompra,
        ),
      ),
    );
  }

  void _navigateToListaFavoritos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaFavoritosInterfaz(
          listaFavoritos: listaFavoritos,
        ),
      ),
    );
  }

  void _showAddProductDialog(Producto producto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Añadir producto'),
          content: Text('¿Deseas añadir este producto a la lista de compra o a favoritos?'),
          actions: [
            TextButton(
              child: Text('Lista de Compra'),
              onPressed: () {
                setState(() {
                  listaCompra.productos.add(producto);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${producto.nombre} ha sido añadido a la lista de la compra')),
                );
              },
            ),
            TextButton(
              child: Text('Favoritos'),
              onPressed: () {
                setState(() {
                  listaFavoritos.productos.add(producto);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${producto.nombre} ha sido añadido a la lista de favoritos')),
                );
              },
            ),
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Busqueda producto'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: _navigateToListaCompra,
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: _navigateToListaFavoritos,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Busca un producto',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchProducts,
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
              child: ListView.builder(
                itemCount: _productos.length,
                itemBuilder: (context, index) {
                  final producto = _productos[index];
                  final imageUrl = producto.foto;
                  final precioMedida = producto.precioMedida > 0 ? ' (€${producto.precioMedida.toStringAsFixed(2)}/kg)' : '';

                  return ListTile(
                    title: Text(producto.nombre),
                    subtitle: Text('${producto.tienda} - €${producto.precio.toStringAsFixed(2)}$precioMedida'),
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
                    onTap: () {
                      _showAddProductDialog(producto);
                    },
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

