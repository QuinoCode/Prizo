import 'package:flutter/material.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/features/lista_favoritos/application/lista_favoritos_service.dart';
import 'package:prizo/main.dart';
import 'package:provider/provider.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/features/pantalla_producto/presentation/pantalla_producto_interfaz.dart';

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
  bool _isLoading = true;
  ListaCompra listaCompra = ListaCompra(
      id: '1', usuario: 'usuario_demo', productos: []);
  ListaFavoritos listaFavoritos = ListaFavoritos(
      id: '1', usuario: 'usuario_demo', productos: []);

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
      listaFavoritosService.DB_generarNombres_JR(),
      listaCompraService.DB_fetchProducts(),
      listaCompraService.DB_generarNombres_JR(),
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
    Provider.of<PrizoState>(context, listen: false).setIndex(4);
  }

  void _navigateToListaCompra() async {
    Provider.of<PrizoState>(context, listen: false).setIndex(5);
  }

  void _navigateToProductInfo(Producto producto) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetallesProducto(
          producto: producto,
          listaCompra: listaCompra,
          listaFavoritos: listaFavoritos,
        ),
      ),
    );
    setState(() {
      _isLoading = true;
    });

    // Cargar todas las listas y productos en paralelo y asignarlas correctamente
    final resultados = await Future.wait([
      listaFavoritosService.generar_ListaFavoritos(),
      listaCompraService.generar_ListaCompra(),
      listaFavoritosService.DB_fetchProducts(),
      listaFavoritosService.DB_generarNombres_JR(),
      listaCompraService.DB_fetchProducts(),
      listaCompraService.DB_generarNombres_JR(),
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

  Widget _buildProductList(String title, List<Producto> productos, List<String> nombres, VoidCallback onNavigate, bool esCompra) {
    return Builder(
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return SizedBox(
          height: MediaQuery.of(context).size.longestSide * 0.35,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: screenWidth * 0.0966,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.041),
                    GestureDetector(
                      onTap: onNavigate,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.1416)
                          ..translate(0.0, -screenHeight * -0.0045),
                        child: ImageIcon(
                          AssetImage('assets/icons/arrow.png'),
                          size: screenWidth * 0.0622748,
                          color: Color(0xFF121212),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading) 
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.longestSide * 0.075),
                  child: SizedBox(
                      height: MediaQuery.of(context).size.longestSide * 0.094,
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF95B3FF), ))
                    )
                )
              else if (productos.isEmpty || nombres.isEmpty)
                Align(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    esCompra 
                    ? Image.asset('assets/images/cesta_vacia.png', height: screenHeight * 0.18)
                    : Image.asset('assets/images/bolsa_de_tela_vacia.png', height: screenHeight * 0.18),
                    SizedBox(height: screenHeight * 0.030,),
                      esCompra 
                      ? Text(
                          "Tu lista de la compra está vacía",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04293,
                            color: Color(0xFF504F4F),
                          ),
                        ) 
                      : Text(
                          "Tu lista de favoritos está vacía",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04293,
                            color: Color(0xFF504F4F),
                          ),
                        )
                    ],
                  ),
                )
              else
                SizedBox(
                  height: screenHeight * 0.25,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productos.length,
                    itemBuilder: (context, index) => _buildProduct(productos[index], nombres[index], esCompra, screenWidth, screenHeight, index, productos.length),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProduct(Producto producto, String nombre, bool esCompra, double screenWidth, double screenHeight, int index, int total) {
    return FutureBuilder<bool>(
      future: listaCompraService.DB_Tick_tiene_tick(producto),
      builder: (context, snapshot) {
        final tieneTick = snapshot.data ?? false;
        final iconPath = tieneTick ? 'assets/icons/checked_checkbox.png' : 'assets/icons/empty_checkbox.png';

        return Row(
          children: [
            Container(
              width: screenWidth * 0.4,
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToProductInfo(producto),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        child: SizedBox(
                          width: screenWidth * 1,
                          height: screenWidth * 1,
                          child: Image.network(
                            producto.foto,
                            fit: BoxFit.contain, // Puedes probar BoxFit.fill si deseas forzar el tamaño exacto
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/images/placeholder.png',
                              width: screenWidth * 0.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  GestureDetector(
                    onTap: () => _navigateToProductInfo(producto),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        nombre,
                        style: TextStyle(fontSize: screenWidth * 0.04293),
                      ),
                    ),
                  ),
                  if (esCompra)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Transform.translate(
                        offset: Offset(-screenWidth * 0.03, 0), // Desplaza el tick a la izquierda
                        child: GestureDetector(
                          onTap: () async {
                            if (tieneTick) {
                              await listaCompraService.DB_Tick_quitar(producto);
                            } else {
                              await listaCompraService.DB_Tick_annadir(producto);
                            }
                            setState(() {
                            });
                          },
                          child: Image.asset(
                            iconPath,
                            width: screenWidth * 0.106,
                            height: screenWidth * 0.106,
                          ),
                        ),
                      ),
                    ),
                  if (!esCompra)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Transform.translate(
                        offset: Offset(-screenWidth * 0.03, 0), // Desplaza el tick a la izquierda
                        child: Icon(
                          Icons.circle,
                          size: screenWidth * 0.106,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (index != total - 1)
              Container(
                width: screenWidth * 0.0055,
                height: screenHeight * (esCompra ? 0.23 : 0.16),
                color: Color(0xFF95B3FF),
                transform: esCompra ? Matrix4.identity() : Matrix4.translationValues(0, -screenHeight * 0.02, 0),
              ),
          ],
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant ListaInterfaz oldWidget) {
    super.didUpdateWidget(oldWidget);
    initializeData();
  }

  @override
  Widget build(BuildContext context) {
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
