import 'dart:async';
import 'package:flutter/material.dart';
import '../../features/obtencion_producto/application/carrefour_finder_service.dart';
import '../../features/obtencion_producto/application/consum_finder_service.dart';
import '../../features/obtencion_producto/application/dia_finder_service.dart';
import '../../features/comparacion_productos/application/comparacion_producto.dart';
import '../../shared/data_entities/models/lista_compra.dart';
import '../../shared/data_entities/models/lista_favoritos.dart';
import '../../shared/data_entities/models/producto.dart';
import '../../features/lista_compra/presentation/lista_compra_interfaz.dart';
import '../../features/lista_compra/application/lista_compra_service.dart';
import '../../features/lista_favoritos/presentation/lista_favoritos_interfaz.dart';
import '../../features/pantalla_producto/presentation/pantalla_producto_interfaz.dart';
import '../lista_favoritos/application/lista_favoritos_service.dart';
import 'package:prizo/features/filtro_busqueda/filtro_busqueda.dart';
import 'package:prizo/features/escaner/presentation/interfaz_scanner.dart';

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

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  ProductSearchScreenState createState() => ProductSearchScreenState();
}

class ProductSearchScreenState extends State<ProductSearchScreen> {
  final ConsumFinderService consumService = ConsumFinderService();
  final DiaFinderService diaService = DiaFinderService();
  final CarrefourFinderService carrefourService = CarrefourFinderService();
  final TextEditingController _searchController = TextEditingController();
  List<Producto> _productos = [];
  List<Producto> _productosRestantes = [];
  bool _isLoading = false;
  final ListaCompraService listaCompraService = ListaCompraService();
  final ListaFavoritosService listaFavoritosService = ListaFavoritosService();
  ListaCompra listaCompra = ListaCompra(
      id: '1', usuario: 'usuario_demo', productos: []);
  ListaFavoritos listaFavoritos = ListaFavoritos(
      id: '1', usuario: 'usuario_demo', productos: []);
  List<int> alergenosSeleccionados = [];
  List<String> tiendasSeleccionadas = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  void _toggleTienda(String tienda) {
    setState(() {
      if (tiendasSeleccionadas.contains(tienda)) {
        tiendasSeleccionadas.remove(tienda);
      } else {
        tiendasSeleccionadas.add(tienda);
      }
    });
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
      List<List<Producto>> productosFiltrados = [];
      if (productos.isNotEmpty) {
        if (tiendasSeleccionadas.isNotEmpty && alergenosSeleccionados.isNotEmpty) {
          for (var lista in productos) {
            if (lista.isNotEmpty && tiendasSeleccionadas.contains(lista[0].tienda)) {
              List<Producto> listaAuxiliar = [];
              for (var producto in lista) {
                bool meter = true;
                for (var indice in alergenosSeleccionados) {
                  if (!(indice < 0 || indice >= producto.alergenos.length) && producto.alergenos[indice]) {
                    meter = false;
                    break;
                  }
                }
                if (meter) {
                  listaAuxiliar.add(producto);
                }
              }
              if (listaAuxiliar.isNotEmpty) {
                productosFiltrados.add(listaAuxiliar);
              }
            }
          }
        } else if (tiendasSeleccionadas.isNotEmpty) {
          for (var lista in productos) {
            if (lista.isNotEmpty && tiendasSeleccionadas.contains(lista[0].tienda)) {
              productosFiltrados.add(lista);
            }
          }
        } else if (alergenosSeleccionados.isNotEmpty) {
          for (var lista in productos) {
            if (lista.isNotEmpty) {
              List<Producto> listaAuxiliar = [];
              for (var producto in lista) {
                for (var indice in alergenosSeleccionados) {
                  if (!(indice < 0 || indice >= producto.alergenos.length) && producto.alergenos[indice]) {
                    listaAuxiliar.add(producto);
                  }
                }
              }
              if (listaAuxiliar.isNotEmpty) {
                productosFiltrados.add(listaAuxiliar);
              }
            }
          }
        } else {
          productosFiltrados = productos;
        }
      }

      // Por cada súper separa los productos en dos listas
      List<(List<Producto>, List<Producto>)> listasSeparadas = productosFiltrados.map((productosSuper) => ordenaPrioridadCategoria(productosSuper)).toList();

      // Combina las primeras listas de cada supermercado y las segundas de cada supermercado entre ellas
      final (List<Producto> listaCategoria, List<Producto> listaRestante) = combinaListasSupers(listasSeparadas);
      setState(() {
        _productos = listaCategoria;
        _productosRestantes = listaRestante;
      });
      if (productosFiltrados.isEmpty) {
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

  void _navigateToFilterList() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FiltroProductosInterfaz(
              alergenos: alergenosSeleccionados,
            ),
      ),
    );
  }

  void _navigateToListaEscaner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const ScannerInterface(),
      ),
    );
  }
  void _navigateToListaCompra() {
    List<(Producto, int)> productosFiltrados = [];
    if (listaCompra.productos.isNotEmpty && tiendasSeleccionadas.isNotEmpty) {
      for (var producto in listaCompra.productos) {
        if (tiendasSeleccionadas.contains(producto.$1.tienda)) {
          productosFiltrados.add(producto);
        }
      }
    } else {
      productosFiltrados = listaCompra.productos;
    }
    ListaCompra comprasFiltradas = new ListaCompra(id: listaFavoritos.id, usuario: listaFavoritos.usuario, productos: productosFiltrados);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ListaCompraInterfaz(
              listaCompra: comprasFiltradas,
              tiendasSeleccionadas : tiendasSeleccionadas,
              original: listaCompra,
            ),
      ),
    );
  }

  void _navigateToListaFavoritos() {
    List<Producto> productosFiltrados = [];
    if (listaFavoritos.productos.isNotEmpty && tiendasSeleccionadas.isNotEmpty) {
      for (var producto in listaFavoritos.productos) {
        if(tiendasSeleccionadas.contains(producto.tienda)) {
          productosFiltrados.add(producto);
        }
      }
    } else {
      productosFiltrados = listaFavoritos.productos;
    }
    ListaFavoritos favoritosFiltrados = new ListaFavoritos(id: listaFavoritos.id, usuario: listaFavoritos.usuario, productos: productosFiltrados);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ListaFavoritosInterfaz(
              listaFavoritos: favoritosFiltrados,
              listaCompra: listaCompra,
              tiendasSeleccionadas : tiendasSeleccionadas,
              original: listaFavoritos,
            ),
      ),
    );
  }

  void _showAddProductDialog(Producto producto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Añadir producto'),
          content: const Text(
              '¿Deseas añadir este producto a la lista de compra o a favoritos?'),
          actions: [
            TextButton(
              child: const Text('Lista de Compra'),
              onPressed: () {
                setState(() {
                  listaCompraService.annadirProducto(listaCompra, producto);
                });
                Navigator.of(context).pop();
                /*ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${producto.nombre} ha sido añadido a la lista de la compra')),
                );*/
              },
            ),
            TextButton(
              child: const Text('Favoritos'),
              onPressed: () {
                setState(() {
                  listaFavoritosService.annadirProducto(listaFavoritos, producto);
                });
                Navigator.of(context).pop();
                /*ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${producto.nombre} ha sido añadido a la lista de favoritos')),
                );*/
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
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
    bool tieneDia = tiendasSeleccionadas.contains("DIA");
    bool tieneConsum = tiendasSeleccionadas.contains("CONSUM");
    bool tieneCarrefour = tiendasSeleccionadas.contains("Carrefour");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Busqueda producto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.scanner),
            onPressed: _navigateToListaEscaner,
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _navigateToListaCompra,
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: _navigateToListaFavoritos,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _navigateToFilterList,
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
                  icon: const Icon(Icons.search),
                  onPressed: _searchProducts,
                ),
              ),
              textInputAction: TextInputAction.search,
              // Escuchamos el evento onSubmitted para detectar cuando se presiona "Enter"
              onSubmitted: (query) {
                _searchProducts(); // Llamamos a la función de búsqueda al presionar "Enter"
              },
            ),
            SizedBox(height: 10),
            /* Botones para Dia, Consum y Carrefour */
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _toggleTienda("DIA");
                    _searchProducts();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tieneDia ? Colors.lightBlueAccent : Colors.white,
                    side: BorderSide(color: Colors.lightBlueAccent),
                  ),
                  child: const Text("Día"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _toggleTienda("CONSUM");
                    _searchProducts();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tieneConsum ? Colors.lightBlueAccent : Colors.white,
                    side: BorderSide(color: Colors.lightBlueAccent),
                  ),
                  child: const Text("Consum"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _toggleTienda("Carrefour");
                    _searchProducts();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tieneCarrefour ? Colors.lightBlueAccent : Colors.white,
                    side: BorderSide(color: Colors.lightBlueAccent),
                  ),
                  child: const Text("Carrefour"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mostrar la primera lista de productos
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _productos.length,
                      itemBuilder: (context, index) {
                        final producto = _productos[index];
                        return _buildProductTile(producto);
                      },
                    ),
                    // Mostrar la segunda lista si hay productos restantes
                    if (_productosRestantes.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Quizás estabas buscando...',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight
                            .bold),
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
      ),
    );
  }

  Widget _buildProductTile(Producto producto) {
    final imageUrl = producto.foto;
    final precioMedida = producto.precioMedida > 0 ? ' (${producto.precioMedida.toStringAsFixed(2)}€/kg)' : '';
    return ListTile(
      title: Text(producto.nombre),
      subtitle: Text('${producto.tienda} - ${producto.precio.toStringAsFixed(2)}€$precioMedida'),
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
      // Icono de + a la derecha
      trailing: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          // Al tocar el ícono de +, se muestra el diálogo para añadir el producto
          _showAddProductDialog(producto);
        },
      ),
    );
  }
}