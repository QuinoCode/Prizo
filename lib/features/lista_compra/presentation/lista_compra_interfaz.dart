import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/lista_compra.dart';
import 'package:prizo/shared/data_entities/producto.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';

class ListaCompraInterfaz extends StatefulWidget {
  final ListaCompra listaCompra;

  ListaCompraInterfaz({super.key, required this.listaCompra});

  @override
  _ListaCompraInterfazState createState() => _ListaCompraInterfazState();
}

class _ListaCompraInterfazState extends State<ListaCompraInterfaz> {
  final ListaCompraService listaCompraService = ListaCompraService();

  @override
  Widget build(BuildContext context) {
    final listaCompraAuxiliar = listaCompraService.crearListaCompraAuxiliar(widget.listaCompra);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tu Lista de la Compra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: listaCompraAuxiliar.productos.isEmpty
            ? Center(child: Text('Tu lista de la compra está vacía.'))
            : ListView.builder(
          itemCount: listaCompraAuxiliar.productos.length,
          itemBuilder: (context, index) {
            final producto = listaCompraAuxiliar.productos[index];
            final cantidad = listaCompraAuxiliar.cantidades[index];
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /* Botón de eliminar cantidad (restar uno) */
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (cantidad == 1) {
                        _showConfirmDeleteDialog(context, producto);
                      } else {
                        setState(() {
                          listaCompraService.removeProduct(widget.listaCompra, producto);
                        });
                      }
                    },
                  ),
                  /* Campo de texto para cambiar la cantidad */
                  Container(
                    width: 50,
                    child: TextField(
                      controller: TextEditingController(text: cantidad.toString()),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(8.0),
                      ),
                      onSubmitted: (newQuantity) {
                        int? newQuantityInt = int.tryParse(newQuantity);
                        if (newQuantityInt != null && newQuantityInt > 1) {
                          setState(() {
                            listaCompraService.setProductQuantity(widget.listaCompra, producto, newQuantityInt);
                          });
                        }
                      },
                    ),
                  ),
                  /* Botón de aumentar cantidad (sumar uno) */
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        listaCompraService.addProduct(widget.listaCompra, producto);
                      });
                    },
                  ),
                  /* Botón de papelera para eliminar producto (poner cantidad a 0) */
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        listaCompraService.setProductQuantity(widget.listaCompra, producto, 0);
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

  /* Método para mostrar el diálogo de confirmación de eliminación */
  void _showConfirmDeleteDialog(BuildContext context, Producto producto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar este producto de la lista de compra?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                setState(() {
                  listaCompraService.removeProduct(widget.listaCompra, producto);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}