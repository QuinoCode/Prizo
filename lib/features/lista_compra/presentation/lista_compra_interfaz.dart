import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/lista_compra.dart';
import 'package:prizo/shared/data_entities/producto.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/shared/application/producto_service.dart';

class ListaCompraInterfaz extends StatefulWidget {
  final ListaCompra listaCompra;

  ListaCompraInterfaz({super.key, required this.listaCompra});

  @override
  _ListaCompraInterfazState createState() => _ListaCompraInterfazState();
}

class _ListaCompraInterfazState extends State<ListaCompraInterfaz> {
  final ListaCompraService listaCompraService = ListaCompraService();
  final ProductoService productoService = new ProductoService();
  bool _isImageTapped = false;
  Producto? _selectedProducto;
  Map<String, TextEditingController> _cantidadControllers = {}; /* Mapa de controladores */
  String? _warningMessage;  /* Mensaje de advertencia */
  GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();/* Key para el scaffold */

  /* Método para mostrar el cuadro de diálogo de confirmación */
  Future<void> _showConfirmDialog(BuildContext context, Producto producto) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, /* Evita cerrar el diálogo tocando fuera de él */
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Eliminar producto?'),
          content: Text('¿Estás seguro de que deseas eliminar el producto ${producto.nombre}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                /* El producto no se ha borrado y ponemos la cantidad actual del producto en el TextField */
                actualizarController(producto);
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

  /* Función que maneja el input numérico en el TextField */
  void _handleInputChange(String input) {
    /* Verificar que solo se introduzcan números */
    if (input.isNotEmpty && RegExp(r'[^0-9]').hasMatch(input)) {
      /* Si no es un número, mostrar un mensaje de advertencia */
      setState(() {
        _warningMessage = 'Solo números';
      });
      /* Evitar que se agregue el carácter no permitido */
      /* Esta parte lo hace imposible */
      _cantidadControllers.forEach((key, controller) {
        controller.text = controller.text.substring(0, controller.text.length - 1);
      });
    } else {
      setState(() {
        _warningMessage = null;  /* Limpiar el mensaje de advertencia si el input es válido */
      });
    }
  }

  void actualizarController(Producto producto) {
    _cantidadControllers[productoService.generateKey(producto)]!.text = listaCompraService
        .getProductQuantity(widget.listaCompra, producto)
        .toString();
  }

  /* Crear el controlador para cada producto */
  TextEditingController _getCantidadController(Producto producto) {
    String key = productoService.generateKey(producto);
    if (!_cantidadControllers.containsKey(key)) {
      /* Si no existe el controlador, lo creamos */
      _cantidadControllers[key] = TextEditingController();
      _cantidadControllers[key]!.text = listaCompraService
          .getProductQuantity(widget.listaCompra, producto)
          .toString();
    }
    return _cantidadControllers[key]!;
  }

  @override
  Widget build(BuildContext context) {
    /* Calcular el precio total */
    double totalPrice = listaCompraService.getTotalPrice(widget.listaCompra);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Tu Lista de la Compra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.listaCompra.productos.isEmpty
            ? Center(child: Text('Tu lista de la compra está vacía.'))
            : Column(
          children: [
            /* Mostrar el mensaje de advertencia (si existe) */
            if (_warningMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _warningMessage!,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            /* Lista de productos */
            Expanded(
              child: ListView.builder(
                itemCount: widget.listaCompra.productos.length,
                itemBuilder: (context, index) {
                  final productoTuple = widget.listaCompra.productos[index];
                  final producto = productoTuple.$1;
                  final cantidad = productoTuple.$2;
                  final totalPriceForProduct = listaCompraService.getPrice(widget.listaCompra, producto);

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          /* Mostrar detalles del producto al hacer clic en la imagen */
                          setState(() {
                            _isImageTapped = !_isImageTapped;
                            _selectedProducto = producto;
                          });
                        },
                        child: ListTile(
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
                              /* Botón "-" para eliminar una instancia con confirmación */
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  if (cantidad > 1) {
                                    /* Disminuir una instancia del producto */
                                    setState(() {
                                      /* Actualizamos la cantidad utilizando el método correspondiente */
                                      listaCompraService.removeInstance(widget.listaCompra, producto);
                                      /* Actualizamos el controlador para reflejar el cambio */
                                      actualizarController(producto);
                                    });
                                  } else {
                                    /* Mostrar cuadro de confirmación para eliminar el producto */
                                    _showConfirmDialog(context, producto);
                                  }
                                },
                              ),
                              /* Campo de cantidad con un TextField para editar */
                              Container(
                                width: 50,
                                child: TextField(
                                  controller: _getCantidadController(producto),
                                  keyboardType: TextInputType.number,
                                  onChanged: _handleInputChange,
                                  decoration: InputDecoration(
                                    hintText: cantidad.toString(),
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                  ),
                                  textAlign: TextAlign.center,
                                  onSubmitted: (value) {
                                    /* Al hacer "Hecho" o "Enter", actualizar la cantidad */
                                    int newQuantity = int.tryParse(value) ?? cantidad;
                                    if(newQuantity > 0) {
                                      setState(() {
                                        /* Actualizar la cantidad usando el método de listaCompraService */
                                        listaCompraService.setProductQuantity(widget.listaCompra, producto, newQuantity);
                                        /* Actualizamos el TextField con la nueva cantidad */
                                        actualizarController(producto);
                                      });
                                    } else {
                                      /* Mostrar cuadro de confirmación para eliminar el producto */
                                      _showConfirmDialog(context, producto);
                                    }
                                  },
                                ),
                              ),
                              /* Botón "+" para agregar una instancia */
                              IconButton(
                                icon: Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    /* Actualizamos la cantidad utilizando el método correspondiente */
                                    listaCompraService.addInstance(widget.listaCompra, producto);
                                    /* Actualizamos el controlador para reflejar el cambio */
                                    actualizarController(producto);
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
                        ),
                      ),
                      /* Mostrar el nombre y el precio debajo de la imagen */
                      if (_isImageTapped && _selectedProducto == producto)
                        Column(
                          children: [
                            SizedBox(height: 8),
                            Text(
                              producto.nombre,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${producto.tienda} - €${producto.precio.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                    ],
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