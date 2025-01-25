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

  Widget _buildProductList(String title, List<Producto> productos, List<String> nombres, VoidCallback onNavigate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          trailing: Icon(Icons.arrow_forward),
          onTap: onNavigate,
        ),
        if (productos.isEmpty || nombres.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              "$title no tiene elementos",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          SizedBox(
            height: 200, // Altura fija para el contenedor horizontal
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                final nombre = nombres[index];
                return Container(
                  width: 150, // Ancho fijo para cada elemento
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            producto.foto,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        nombre,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          _buildProductList("Lista de compra", productosCompra, productosCompraNombre, _navigateToListaCompra),
          Divider(),
          _buildProductList("Lista de favoritos", productosFavoritos, productosFavoritosNombre, _navigateToListaFavoritos),
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