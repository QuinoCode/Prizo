import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/producto.dart';
import 'package:prizo/shared/data_entities/lista_compra.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';

class ListaCompraInterfaz extends StatefulWidget {
  final ListaCompra listaCompra;

  ListaCompraInterfaz({super.key, required this.listaCompra});

  @override
  _ListaCompraInterfazState createState() => _ListaCompraInterfazState();
}

class _ListaCompraInterfazState extends State<ListaCompraInterfaz> {
  final ListaCompraService listaCompraService = ListaCompraService();

  // Método para mostrar el cuadro de texto de cantidad y validar la entrada
  void _editQuantity(ProductoCompra productoCompra) async {
    TextEditingController _quantityController = TextEditingController(text: productoCompra.cantidad.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modificar cantidad'),
          content: TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Cantidad'),
            autofocus: true,
            onChanged: (value) {
              // Solo permitir números enteros y mayores que 0
              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                // Si la entrada no es válida, no se hace nada o se puede dar un aviso.
                return;
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirmar'),
              onPressed: () {
                int newQuantity = int.tryParse(_quantityController.text) ?? 0;

                if (newQuantity > 0) {
                  setState(() {
                    productoCompra.cantidad = newQuantity;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cantidad actualizada a $newQuantity')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, ingresa un número válido mayor que 0')),
                  );
                }

                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
          ],
        );
      },
    );
  }

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
            final productoCompra = widget.listaCompra.productos[index];
            final producto = productoCompra.producto;
            final imageUrl = producto.foto;

            return ListTile(
              leading: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image);
                },
              )
                  : Icon(Icons.image_not_supported),
              title: Text(producto.nombre),
              subtitle: Text('${producto.tienda} - €${producto.precio.toStringAsFixed(2)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón para reducir la cantidad del producto
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      // Comprobar si el producto tiene solo una instancia
                      if (productoCompra.cantidad == 1) {
                        // Mostrar el diálogo de confirmación solo si es la única instancia
                        _showConfirmDeleteDialog(producto);
                      } else {
                        // Si hay más de una instancia, simplemente reducir la cantidad
                        setState(() {
                          productoCompra.cantidad--;
                        });
                      }
                    },
                  ),
                  // Mostrar la cantidad del producto
                  GestureDetector(
                    onTap: () => _editQuantity(productoCompra), // Permite editar la cantidad
                    child: Text(
                      '${productoCompra.cantidad}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Botón para añadir más instancias del producto
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        listaCompraService.addProduct(widget.listaCompra, producto);
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

  // Método para mostrar el diálogo de confirmación
  void _showConfirmDeleteDialog(Producto producto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Quieres borrar el producto?'),
          content: Text('¿Estás seguro de que deseas eliminar ${producto.nombre} de tu lista de la compra?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo sin hacer nada
              },
            ),
            TextButton(
              child: Text('Confirmar'),
              onPressed: () {
                setState(() {
                  listaCompraService.removeProduct(widget.listaCompra, producto);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${producto.nombre} ha sido eliminado de la lista.')),
                );
                Navigator.of(context).pop(); // Cerrar el diálogo después de eliminar el producto
              },
            ),
          ],
        );
      },
    );
  }
}