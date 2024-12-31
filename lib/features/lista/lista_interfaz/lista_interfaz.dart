import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/features/lista/lista_service/lista_service.dart';
import 'package:prizo/features/lista_compra/presentation/lista_compra_interfaz.dart';
import 'package:prizo/features/lista_favoritos/presentation/lista_favoritos_interfaz.dart';

class ListaInterfaz extends StatefulWidget {
  final List<String> tiendasSeleccionadas;
  final ListaCompra listaCompra;
  final ListaFavoritos listaFavoritos;
  final ListaCompra listaCompraOriginal;
  final ListaFavoritos listaFavoritosOriginal;

  ListaInterfaz({
    super.key,
    required this.tiendasSeleccionadas,
    required this.listaCompra,
    required this.listaCompraOriginal,
    required this.listaFavoritos,
    required this.listaFavoritosOriginal,
  });

  @override
  _ListaState createState() => _ListaState();
}

class _ListaState extends State<ListaInterfaz> {
  ListaService listaService = ListaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Lista de Productos'),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildCompraList() {
    final productosComprados = listaService.obtenerComprados(widget.listaCompra);
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
  }

  Widget _buildFavoritosList() {
    final productosFavoritos = listaService.obtenerFavoritos(widget.listaFavoritos);
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

  Widget _buildHorizontalList(List<Producto> productos, {required bool isCompra}) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto = productos[index];
          return _buildProductCard(producto, isCompra);
        },
      ),
    );
  }

  Widget _buildProductCard(Producto producto, bool isCompra) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Stack(
        children: [
          Column(
            children: [
              Image.network(
                producto.foto,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported, size: 80),
              ),
              const SizedBox(height: 8),
              Text(
                producto.nombre,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          if (isCompra)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.circle_outlined, color: Colors.blue),
                onPressed: () {
                  setState(() {
                    listaService.borrarComprado(
                      widget.listaCompra,
                      widget.listaCompraOriginal,
                      producto,
                    );
                  });
                },
              ),
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
          listaFavoritos: widget.listaFavoritos,
          listaCompra: widget.listaCompraOriginal,
          tiendasSeleccionadas: widget.tiendasSeleccionadas,
          original: widget.listaFavoritosOriginal,
        ),
      ),
    );
  }

  void _navigateToListaCompra() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaCompraInterfaz(
          listaCompra: widget.listaCompra,
          tiendasSeleccionadas: widget.tiendasSeleccionadas,
          original: widget.listaCompraOriginal,
        ),
      ),
    );
  }
}