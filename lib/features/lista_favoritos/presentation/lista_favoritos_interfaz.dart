import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/lista_favoritos.dart';

class ListaFavoritosInterfaz extends StatelessWidget {
  final ListaFavoritos listaFavoritos;

  const ListaFavoritosInterfaz({super.key, required this.listaFavoritos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Lista de Favoritos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: listaFavoritos.productos.isEmpty
            ? const Center(
          child: Text('Tu lista de favoritos está vacía.'),
        )
            : ListView.builder(
          itemCount: listaFavoritos.productos.length,
          itemBuilder: (context, index) {
            final producto = listaFavoritos.productos[index];
            return ListTile(
              title: Text(producto.nombre),
              subtitle: Text('${producto.tienda} - €${producto.precio.toStringAsFixed(2)}'),
            );
          },
        ),
      ),
    );
  }
}