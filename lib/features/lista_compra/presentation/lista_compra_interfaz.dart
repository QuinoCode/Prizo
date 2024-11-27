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

  /* Método para mostrar el cuadro de diálogo de confirmación */
  Future<void> _showConfirmDialog(BuildContext context, Producto producto) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Evita cerrar el diálogo tocando fuera de él
      builder: (BuildContext context) {
        return AlertDialog(
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
                  listaCompraService.removeProduct(widget.listaCompra, producto);
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
    /* Calcular el precio total */
    double totalPrice = listaCompraService.getTotalPrice(widget.listaCompra);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tu Lista de la Compra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.listaCompra.productos.isEmpty
            ? Center(child: Text('Tu lista de la compra está vacía.'))
            : Column(
          children: [
            /* Lista de productos */
            Expanded(
              child: ListView.builder(
                itemCount: widget.listaCompra.productos.length,
                itemBuilder: (context, index) {
                  final productoTuple = widget.listaCompra.productos[index];
                  final producto = productoTuple.$1;
                  final cantidad = productoTuple.$2;
                  final totalPriceForProduct = listaCompraService.getPrice(widget.listaCompra, producto);

                  return ListTile(
                    leading: producto.foto.isNotEmpty
                        ? Image.network(
                      producto.foto,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Icon(Icons.image_not_supported);
                      },
                    )
                        : Icon(Icons.image_not_supported),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /* Botón para eliminar una instancia con confirmación */
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if(listaCompraService.getProductQuantity(widget.listaCompra, producto) > 1) {
                              listaCompraService.removeInstance(widget.listaCompra, producto);
                            } else {
                              /* Mostrar el cuadro de confirmación antes de eliminar */
                              _showConfirmDialog(context, producto);
                            }
                          },
                        ),
                        /* Cantidad */
                        Text(
                          '$cantidad',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        /* Botón para agregar una instancia */
                        IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() {
                              listaCompraService.addInstance(widget.listaCompra, producto);
                            });
                          },
                        ),
                        /* Precio total del producto */
                        Text(
                          '${totalPriceForProduct.toStringAsFixed(2)} €',
                          style: TextStyle(fontSize: 20),
                        ),
                        /* Botón de papelera para eliminar el producto completo */
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            /* Mostrar el cuadro de confirmación antes de eliminar */
                            _showConfirmDialog(context, producto);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            /* Muestra el precio total de todos los productos */
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${totalPrice.toStringAsFixed(2)} €',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}