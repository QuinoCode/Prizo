import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/lista_compra.dart';

class ListaCompraInterfaz extends StatelessWidget {
  final ListaCompra listaCompra;

  ListaCompraInterfaz({super.key, required this.listaCompra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tu Lista de la Compra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: listaCompra.productos.isEmpty
            ? Center(
          child: Text('Tu lista de la compra está vacía.'),
        )
            : ListView.builder(
          itemCount: listaCompra.productos.length,
          itemBuilder: (context, index) {
            final producto = listaCompra.productos[index];
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
