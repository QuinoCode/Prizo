import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/lista_compra.dart';
import 'package:prizo/shared/data_entities/producto.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';

class ListaCompraInterfaz extends StatefulWidget {
  final ListaCompra2 listaCompra;

  ListaCompraInterfaz({super.key, required this.listaCompra});

  @override
  _ListaCompraInterfazState createState() => _ListaCompraInterfazState();
}

class _ListaCompraInterfazState extends State<ListaCompraInterfaz> {
  final ListaCompraService listaCompraService = ListaCompraService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tu Lista de la Compra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.listaCompra.productos.isEmpty
            ? Center(child: Text('Tu lista de la compra está vacía.'))
            : ListView.builder(
          itemCount: widget.listaCompra.productos.length,
          itemBuilder: (context, index) {
            final productoTuple = widget.listaCompra.productos[index];
            final producto = productoTuple.$1;
            final cantidad = productoTuple.$2;

            // Si el producto no tiene imagen, se muestra el ícono de imagen rota
            return ListTile(
              leading: producto.foto.isNotEmpty
                  ? Image.network(
                producto.foto,
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Icon(Icons.broken_image);
                },
              )
                  : Icon(Icons.image_not_supported),
              title: null, // Eliminar el nombre del producto
              subtitle: null, // Eliminar la descripción del producto
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$cantidad',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        listaCompraService.removeProduct(widget.listaCompra, producto);
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}