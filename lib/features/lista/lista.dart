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
    _initializeProductosFavoritos();
    _initializeNombresFavoritos();
    _initializeProductosCompra();
    _initializeNombresCompra();
    _initializeListaFavoritos();
    _initializeListaCompra();
  }
  void _initializeListaFavoritos() async {
    // Llama a generar_ListaFavoritos y espera el resultado
    ListaFavoritos fetchedListaFavoritos = await listaFavoritosService.generar_ListaFavoritos();

    // Actualiza el estado con los datos obtenidos
    setState(() {
      listaFavoritos = fetchedListaFavoritos;
    });
  }
  void _initializeListaCompra() async {
    // Llama a generar_ListaCompra y espera el resultado
    ListaCompra fetchedListaCompra = await listaCompraService.generar_ListaCompra();

    // Actualiza el estado con los datos obtenidos
    setState(() {
      listaCompra = fetchedListaCompra;
    });
  }
  void _initializeProductosFavoritos() async {
    List<Producto> productos = await listaFavoritosService.DB_fetchProducts();
    setState(() {
      productosFavoritos = productos;
    });
  }
  void _initializeNombresFavoritos() async {
    List<String> nombres = await listaFavoritosService.DB_generarNombres();
    setState(() {
      productosFavoritosNombre = nombres;
    });
  }
  void _initializeProductosCompra() async {
    List<Producto> productos = await listaCompraService.DB_fetchProducts();
    setState(() {
      productosCompra = productos;
    });
  }
  void _initializeNombresCompra() async {
    List<String> nombres = await listaCompraService.DB_generarNombres();
    setState(() {
      productosCompraNombre = nombres;
    });
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

  void _navigateToListaFavoritos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ListaFavoritosInterfaz(
              listaFavoritos: listaFavoritos,
              listaCompra: listaCompra,
              original: listaFavoritos,
            ),
      ),
    );
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
