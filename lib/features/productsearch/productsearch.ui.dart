import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/data_entities/producto.dart';
import '../../features/obtencion_producto/application/consum_finder_service.dart';
import '../../features/obtencion_producto/application/dia_finder_service.dart';
import '../../features/comparacion_productos/application/comparacion_producto.dart';
import '../../features/obtencion_producto/application/carrefour_finder_service.dart';

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
      print("Error al buscar productos: \$e");
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
        print("No se encontraron productos para la consulta: \${_searchController.text}");
      }
    } catch (e) {
      print("Error al buscar productos: \$e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for a product',
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
                  return ListTile(
                    title: Text(producto.nombre),
                      subtitle: Text('${producto.tienda} - \$${producto.precio.toStringAsFixed(2)}')
                      ,
                    leading: producto.foto.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: \$error');
                        return Icon(Icons.broken_image);
                      },
                    )
                        : Icon(Icons.image_not_supported),
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
