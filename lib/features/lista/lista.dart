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

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    // Cargar todas las listas y productos en paralelo y asignarlas correctamente
    final resultados = await Future.wait([
      listaFavoritosService.generar_ListaFavoritos(),
      listaCompraService.generar_ListaCompra(),
      listaFavoritosService.DB_fetchProducts(),
      listaFavoritosService.DB_generarNombres(),
      listaCompraService.DB_fetchProducts(),
      listaCompraService.DB_generarNombres(),
    ]);

    // Asignar los resultados obtenidos
    listaFavoritos = resultados[0] as ListaFavoritos;
    listaCompra = resultados[1] as ListaCompra;
    productosFavoritos = resultados[2] as List<Producto>;
    productosFavoritosNombre = resultados[3] as List<String>;
    productosCompra = resultados[4] as List<Producto>;
    productosCompraNombre = resultados[5] as List<String>;

    setState(() {
      _isLoading = false;
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
        _isLoading = true;
      });

      final resultados = await Future.wait([
        listaFavoritosService.DB_fetchProducts(),
        listaFavoritosService.DB_generarNombres(),
      ]);

      productosFavoritos = resultados[0] as List<Producto>;
      productosFavoritosNombre = resultados[1] as List<String>;

      setState(() {
        _isLoading = false;
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
        _isLoading = true;
      });

      final resultados = await Future.wait([
        listaCompraService.DB_fetchProducts(),
        listaCompraService.DB_generarNombres(),
      ]);

      productosCompra = resultados[0] as List<Producto>;
      productosCompraNombre = resultados[1] as List<String>;

      setState(() {
        _isLoading = false;
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
                      fontFamily: 'Geist',
                      fontSize: screenWidth * 0.0966,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.048),
                  GestureDetector(
                    onTap: onNavigate, // Navegar solo cuando se pulse la flecha
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(3.1416), // Invierte horizontalmente
                      child: ImageIcon(
                        AssetImage('assets/icons/arrow.png'),
                        size: screenWidth * 0.057,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (productos.isEmpty || nombres.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                child: Text(
                  "    $title no tiene elementos",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04293,
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
                                        style: TextStyle(fontSize: screenWidth * 0.04293),
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
                                    style: TextStyle(fontSize: screenWidth * 0.04293),
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          _buildProductList("Lista de compra", productosCompra, productosCompraNombre, _navigateToListaCompra, true),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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