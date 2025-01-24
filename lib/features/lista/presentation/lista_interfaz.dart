import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/features/lista/application//lista_service.dart';
import 'package:prizo/features/lista_compra/presentation/lista_compra_interfaz.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/features/lista_favoritos/presentation/lista_favoritos_interfaz.dart';
import 'package:prizo/features/lista_favoritos/application/lista_favoritos_service.dart';
import 'package:prizo/shared/database/database_operations.dart';
import 'package:sqflite/sqflite.dart';

Database db = DatabaseOperations.instance.prizoDatabase;

class ListaInterfaz extends StatefulWidget {

  ListaInterfaz({super.key});

  @override
  _ListaState createState() => _ListaState();
}

class _ListaState extends State<ListaInterfaz> {
  final ListaService listaService = ListaService();
  final ListaCompraService listaCompraService = ListaCompraService();
  final ListaFavoritosService listaFavoritosService = ListaFavoritosService();
  ListaCompra listaCompra = ListaCompra(
      id: '1', usuario: 'usuario_demo', productos: []);
  ListaFavoritos listaFavoritos = ListaFavoritos(
      id: '1', usuario: 'usuario_demo', productos: []);

  @override
  void initState() {
    super.initState();
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

  Future<void> _ventanaConfirmacion(BuildContext context, Producto producto) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, /* Evita cerrar el diálogo tocando fuera de él */
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('¿Eliminar producto?'),
          content: Text('¿Estás seguro de que deseas eliminar el producto ${producto.nombre}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                /* Cerrar el diálogo sin hacer nada */
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                /* Eliminar el producto completo de la lista */
                setState(() {
                  listaService.borrarComprado(listaCompra, listaCompra, producto);
                });
                Navigator.of(context).pop(); /* Cerrar el cuadro de diálogo */
              },
              child: Text('Eliminar'),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              'Lista de compra',
                  () => _navigateToListaCompra(),
            ),
            _buildCompraList(),
            _buildSectionHeader(
              context,
              'Lista de favoritos',
                  () => _navigateToListaFavoritos(),
            ),
            _buildFavoritosList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 35),
          ),
          IconButton(
            icon: ImageIcon(AssetImage('assets/icons/farrow.png')),
            iconSize: 36,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildCompraList() {
    DatabaseOperations.instance.fetchProductsListaCompra(db).then((productosComprados) {
      if (productosComprados.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Tu lista de la compra está vacía.',
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        );
      }
      return _buildHorizontalList(productosComprados, isCompra: true);
    });
    return Text("Error de DB");
  }

  Widget _buildFavoritosList() {
    final productosFavoritos = listaService.obtenerFavoritos(listaFavoritos);
    if (productosFavoritos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          'Tu lista de favoritos está vacía.',
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      );
    }
    return _buildHorizontalList(productosFavoritos, isCompra: false);
  }

  String obtenerSubcadena(String input) {
    String result;

    // Verificamos si la longitud es suficiente para acceder al carácter 17
    if (input.length >= 17 && input[16] == ' ') {
      result = input.substring(0, 16);
    } else {
      result = input.substring(0, 8);
    }

    // Comprobamos si el resultado es diferente al original
    if (result.length < input.length) {
      result += "\n" + input.substring(result.length, 17) + "...";  // Agregamos "..." si el resultado es más corto que el original
    }

    return result;
  }


  Widget _buildHorizontalList(List<Producto> productos, {required bool isCompra}) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto = productos[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                _buildProductCard(producto, isCompra),  // El producto
                if (index < productos.length - 1)   // Solo muestra la línea si no es el último producto
                  Container(
                    height: 80,  // Altura de la línea (ajústala según el tamaño de las imágenes)
                    width: 2,    // Ancho de la línea
                    color: Color(0xFF95B3FF), // Color de la línea
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Producto producto, bool isCompra) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          // Imagen del producto
          Image.network(
            producto.foto,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 80),
          ),
          const SizedBox(height: 8),
          // Nombre del producto
          Text(
            obtenerSubcadena(producto.nombre),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
          // Espacio entre el nombre y el icono
          const SizedBox(height: 8),
          // Icono debajo del nombre
          if (isCompra)
            IconButton(
              icon: const Icon(Icons.circle_outlined, color: Color(0xFF95B3FF)),
              onPressed: () {
                _ventanaConfirmacion(context, producto);
              },
            ),
        ],
      ),
    );
  }

  void _navigateToListaFavoritos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaFavoritosInterfaz(
          listaCompra: listaCompra,
          listaFavoritos: listaFavoritos,
          original: listaFavoritos,
        ),
      ),
    );
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
}