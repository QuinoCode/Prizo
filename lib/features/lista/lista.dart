import 'package:flutter/material.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/features/lista_favoritos/application/lista_favoritos_service.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/features/lista_compra/presentation/lista_compra_interfaz.dart';
import 'package:prizo/features/lista_favoritos/presentation/lista_favoritos_interfaz.dart';

class ListaInterfaz extends StatefulWidget {
  ListaInterfaz({super.key});

  @override
  _ListaInterfazState createState() => _ListaInterfazState();
}

class _ListaInterfazState extends State<ListaInterfaz> {
  final ListaCompraService listaCompraService = ListaCompraService();
  final ListaFavoritosService listaFavoritosService = ListaFavoritosService();
  List<Producto> productosCompra = [];
  List<String> productosCompraNombre = [];
  List<Producto> productosFavoritos = [];
  List<String> productosFavoritosNombre = [];
  ListaCompra listaCompra = ListaCompra(
      id: '1', usuario: 'usuario_demo', productos: []);
  ListaFavoritos listaFavoritos = ListaFavoritos(
      id: '1', usuario: 'usuario_demo', productos: []);

  @override
  void initState() {
    super.initState();
    _initializeProductosFavoritos2();
    _initializeProductosCompra2();
  }
  void _initializeProductosFavoritos2() async {
    List<Producto> productos = await listaFavoritosService.DB_fetchProducts();
    setState(() {
      productosFavoritos = productos;
      productosFavoritosNombre = [];
      for(Producto producto in productosFavoritos) {
        // Verificar si la longitud del nombre es suficiente para los índices usados
        if (producto.nombre.length >= 17 && producto.nombre[16] == ' ') {
          // Tomar los primeros 16 caracteres y validar el rango
          String auxiliar = producto.nombre.substring(0, 16);
          if (producto.nombre.length > 16) {
            auxiliar += producto.nombre.substring(16, producto.nombre.length.clamp(16, 17)) + "...";
          }
          productosFavoritosNombre.add(auxiliar);
        } else {
          // Validar rango para nombres cortos
          String auxiliar = producto.nombre.substring(0, producto.nombre.length.clamp(0, 8));
          if (producto.nombre.length > 8) {
            auxiliar += producto.nombre.substring(8, producto.nombre.length.clamp(8, 17)) + "...";
          }
          productosFavoritosNombre.add(auxiliar);
        }
      }
      listaFavoritos = ListaFavoritos(id: '1', usuario: 'usuario_demo', productos: productosFavoritos);
    });
  }
  void _initializeProductosCompra2() async {
    List<(Producto,int)> productos = await listaCompraService.DB_fetchProductsInt();
    setState(() {
      productosCompra = [];
      for(var tupla in productos) {
        productosCompra.add(tupla.$1);
      }
      productosCompraNombre = [];
      for(Producto producto in productosCompra) {
        // Verificar si la longitud del nombre es suficiente para los índices usados
        if (producto.nombre.length >= 17 && producto.nombre[16] == ' ') {
          // Tomar los primeros 16 caracteres y validar el rango
          String auxiliar = producto.nombre.substring(0, 16);
          if (producto.nombre.length > 16) {
            auxiliar += producto.nombre.substring(16, producto.nombre.length.clamp(16, 17)) + "...";
          }
          productosCompraNombre.add(auxiliar);
        } else {
          // Validar rango para nombres cortos
          String auxiliar = producto.nombre.substring(0, producto.nombre.length.clamp(0, 8));
          if (producto.nombre.length > 8) {
            auxiliar += producto.nombre.substring(8, producto.nombre.length.clamp(8, 17)) + "...";
          }
          productosCompraNombre.add(auxiliar);
        }
      }
      listaCompra = ListaCompra(id: '1', usuario: 'usuario_demo', productos: productos);
    });
  }

  void _navigateToListaFavoritos() async {
    // Espera al resultado de la pantalla secundaria
    bool? changesMade = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaFavoritosInterfaz(
          listaFavoritos: listaFavoritos,
          listaCompra: listaCompra,
          original: listaFavoritos,
        ),
      ),
    );

    // Si hubo cambios, actualiza la interfaz
    if (changesMade ?? false) {
      setState(() {
        _initializeProductosFavoritos2();
      });
    }
  }

  void _navigateToListaCompra() async {
    // Espera al resultado de la pantalla secundaria
    bool? changesMade = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaCompraInterfaz(
          listaCompra: listaCompra,
        ),
      ),
    );

    // Si hubo cambios, actualiza la interfaz
    if (changesMade ?? false) {
      setState(() {
        _initializeProductosCompra2();
      });
    }
  }

  Widget _buildProductList(String title, List<Producto> productos, List<String> nombres, VoidCallback onNavigate, bool esCompra) {
    return Builder(
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.085,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Icon(Icons.arrow_forward, size: screenWidth * 0.085),
                ],
              ),
              onTap: onNavigate,
            ),
            if (productos.isEmpty || nombres.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                child: Text(
                  "    $title no tiene elementos",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              SizedBox(
                height: screenHeight * 0.25,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    final nombre = nombres[index];

                    return FutureBuilder<bool>(
                      future: listaCompraService.DB_Tick_tiene_tick(producto),
                      builder: (context, snapshot) {
                        final tieneTick = snapshot.data ?? false;
                        final iconPath = tieneTick
                            ? 'assets/icons/checked_checkbox.png'
                            : 'assets/icons/empty_checkbox.png';

                        return Row(
                          children: [
                            Container(
                              width: screenWidth * 0.4,
                              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                      child: Image.network(
                                        producto.foto,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.image,
                                            size: screenWidth * 0.1,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  esCompra
                                      ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nombre,
                                        style: TextStyle(fontSize: screenWidth * 0.04),
                                      ),
                                      SizedBox(height: screenHeight * 0.005),
                                      GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            if (tieneTick) {
                                              listaCompraService.DB_Tick_quitar(producto);
                                            } else {
                                              listaCompraService.DB_Tick_annadir(producto);
                                            }
                                          });
                                        },
                                        child: Image.asset(
                                          iconPath,
                                          width: screenWidth * 0.08,
                                          height: screenWidth * 0.08,
                                        ),
                                      ),
                                    ],
                                  )
                                      : Text(
                                    nombre,
                                    style: TextStyle(fontSize: screenWidth * 0.04),
                                  ),
                                ],
                              ),
                            ),
                            if (index != productos.length - 1)
                              Container(
                                width: screenWidth * 0.0055,
                                height: screenHeight * 0.25,
                                color: Color(0xFF95B3FF),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03, // Ajusta el espacio aquí
          ),
          _buildProductList("Lista de compra", productosCompra, productosCompraNombre, _navigateToListaCompra, true),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03, // Ajusta el espacio aquí
          ),
          _buildProductList("Lista de favoritos", productosFavoritos, productosFavoritosNombre, _navigateToListaFavoritos, false),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ListaInterfaz(),
  ));
}
