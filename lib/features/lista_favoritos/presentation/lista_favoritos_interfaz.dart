import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/lista_favoritos.dart';
import 'package:prizo/features/lista_favoritos/application/lista_favoritos_service.dart';

class ListaFavoritosInterfaz extends StatelessWidget {
  final ListaFavoritos listaFavoritos;

  ListaFavoritosInterfaz({super.key, required this.listaFavoritos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tu Lista de Favoritos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: listaFavoritos.productos.isEmpty
            ? Center(child: Text('Tu lista de favoritos está vacía.'))
            : ListView.builder(
          itemCount: listaFavoritos.productos.length,
          itemBuilder: (context, index) {
            final producto = listaFavoritos.productos[index];
            final imageUrl = producto.foto;

            return ListTile(
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
              title: Text(producto.nombre),
              subtitle: Text('${producto.tienda} - €${producto.precio.toStringAsFixed(2)}'),
            );
          },
        ),
      ),
    );
  }
}