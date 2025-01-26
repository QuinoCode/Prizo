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
                mainAxisSize: MainAxisSize.min, // Ajustar el ancho al contenido
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.085, // Tamaño de texto basado en el ancho de la pantalla
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.01), // Espaciado entre el texto y el ícono
                  Icon(Icons.arrow_forward, size: screenWidth * 0.05), // Tamaño del ícono ajustado
                ],
              ),
              onTap: onNavigate,
            ),
            if (productos.isEmpty || nombres.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                child: Text(
                  "$title no tiene elementos",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04, // Tamaño de texto basado en el ancho
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              SizedBox(
                height: screenHeight * 0.25, // Altura basada en el 25% de la altura de la pantalla
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    final nombre = nombres[index];
                    return Row(
                      children: [
                        // Producto
                        Container(
                          width: screenWidth * 0.4, // Ancho basado en el 40% del ancho de la pantalla
                          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(screenWidth * 0.02), // Radio basado en el ancho
                                  child: Image.network(
                                    producto.foto,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.image,
                                        size: screenWidth * 0.1, // Tamaño del icono basado en el ancho
                                        color: Colors.grey,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01), // Espaciado basado en la altura
                              esCompra
                                  ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Alinea el texto al inicio (izquierda)
                                children: [
                                  Text(
                                    nombre,
                                    style: TextStyle(fontSize: screenWidth * 0.04), // Tamaño del texto
                                  ),
                                  SizedBox(height: screenHeight * 0.005), // Espaciado entre el texto y el ícono
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end, // Alinea el ícono a la derecha
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        size: screenWidth * 0.05, // Tamaño ajustado al ancho
                                        color: Colors.red, // Cambia el color si lo necesitas
                                      ),
                                    ],
                                  ),
                                ],
                              )
                                  : Text(
                                nombre,
                                style: TextStyle(fontSize: screenWidth * 0.04), // Tamaño de texto basado en el ancho
                              ),
                            ],
                          ),
                        ),
                        // Separador vertical
                        if (index != productos.length - 1) // Evitar barra al final
                          Container(
                            width: screenWidth * 0.0055, // Ancho en relación al ancho del contenedor
                            height: screenHeight * 0.25, // Altura igual a la del contenedor
                            color: Color(0xFF95B3FF), // Color de la barra
                          ),
                      ],
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
      body: ListView(
        children: [
          _buildProductList("Lista de compra", productosCompra, productosCompraNombre, _navigateToListaCompra, true),
          Divider(),
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