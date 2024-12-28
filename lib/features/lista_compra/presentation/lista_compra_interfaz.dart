import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/DAO/lista_compra_DAO.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/shared/application/producto_service.dart';

class ListaCompraInterfaz extends StatefulWidget {
  ListaCompra listaCompra;
  final List<String> tiendasSeleccionadas;
  final ListaCompra original;

  ListaCompraInterfaz({super.key, required this.listaCompra, required this.tiendasSeleccionadas, required this.original});

  @override
  _ListaCompraInterfazState createState() => _ListaCompraInterfazState();
}

class _ListaCompraInterfazState extends State<ListaCompraInterfaz> {
  final ListaCompraService listaCompraService = ListaCompraService();
  final ProductoService productoService = new ProductoService();
  bool _esImagenPulsada = false;
  Producto? _productoSeleccionado;
  Map<String, TextEditingController> _mapaControladorCantidad = {};
  String? _mensajeAdvertencia;
  GlobalKey<ScaffoldMessengerState> _scaffoldClave = GlobalKey<ScaffoldMessengerState>();

  void _mostrarPopUpBolsa(BuildContext context) {
    //ListaCompraDAO listaCompraDAO = new ListaCompraDAO(null);
    //listaCompraDAO.insertListaCompra(widget.listaCompra);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_bag, // Icono de bolsa de compras
                size: 100,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Recuerda coger tu bolsa!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _toggleTienda(String tienda) {
    setState(() {
      if (widget.tiendasSeleccionadas.contains(tienda)) {
        widget.tiendasSeleccionadas.remove(tienda);
      } else {
        widget.tiendasSeleccionadas.add(tienda);
      }
      List<(Producto, int)> productosFiltrados = [];
      if (widget.original.productos.isNotEmpty && widget.tiendasSeleccionadas.isNotEmpty) {
        for (var producto in widget.original.productos) {
          if (widget.tiendasSeleccionadas.contains(producto.$1.tienda)) {
            productosFiltrados.add(producto);
          }
        }
      } else {
        productosFiltrados = widget.original.productos;
      }
      widget.listaCompra = new ListaCompra(id: widget.original.id, usuario: widget.original.usuario, productos: productosFiltrados);
    });
  }

  Future<void> _ventanaConfirmacion(BuildContext context, Producto producto) async {
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
                actualizarCantidadController(producto);
                /* Cerrar el diálogo sin hacer nada */
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                /* Eliminar el producto completo de la lista */
                setState(() {
                  listaCompraService.quitarProducto(widget.listaCompra, producto);
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

  TextEditingController _crearCantidadController(Producto producto) {
    String key = productoService.generarClave(producto);
    if (!_mapaControladorCantidad.containsKey(key)) {
      _mapaControladorCantidad[key] = TextEditingController();
      _mapaControladorCantidad[key]!.text = listaCompraService.getCantidadProducto(widget.listaCompra, producto).toString();
    }
    return _mapaControladorCantidad[key]!;
  }

  void actualizarCantidadController(Producto producto) {
    _mapaControladorCantidad[productoService.generarClave(producto)]!.text = listaCompraService
        .getCantidadProducto(widget.listaCompra, producto)
        .toString();
  }

  void _manejadorTextField(String input) {
    /* Verificar que solo se introduzcan números */
    if (input.isNotEmpty && RegExp(r'[^0-9]').hasMatch(input)) {
      /* Si no es un número, mostrar un mensaje de advertencia*/
      setState(() {
        _mensajeAdvertencia = 'Solo números';
      });
      /* Evitar que se agregue el carácter no permitido */
      /* Esta parte lo hace imposible */
      _mapaControladorCantidad.forEach((key, controller) {
        controller.text = controller.text.substring(0, controller.text.length - 1);
      });
      Future.delayed(Duration(seconds: 2), () {
        /* Limpiar el mensaje de advertencia si han pasado 2 segundos */
        setState(() {
          _mensajeAdvertencia = null;
        });
      });
    } else {
      /* Limpiar el mensaje de advertencia si el input es válido */
      setState(() {
        _mensajeAdvertencia = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool tieneDia = widget.tiendasSeleccionadas.contains("DIA");
    bool tieneConsum = widget.tiendasSeleccionadas.contains("CONSUM");
    bool tieneCarrefour = widget.tiendasSeleccionadas.contains("Carrefour");
    double precioTotal = listaCompraService.getPrecioTotal(widget.listaCompra);

    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldClave,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Tu Lista de la Compra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /* Fila de botones "Día", "Consum", "Carrefour" siempre visibles */
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () { _toggleTienda("DIA"); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tieneDia ? Colors.lightBlueAccent : Colors.white,
                    side: BorderSide(color: Colors.lightBlueAccent),
                  ),
                  child: const Text('Día'),
                ),
                ElevatedButton(
                  onPressed: () { _toggleTienda("CONSUM"); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tieneConsum ? Colors.lightBlueAccent : Colors.white,
                    side: BorderSide(color: Colors.lightBlueAccent),
                  ),
                  child: const Text('Consum'),
                ),
                ElevatedButton(
                  onPressed: () { _toggleTienda("Carrefour"); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tieneCarrefour ? Colors.lightBlueAccent : Colors.white,
                    side: BorderSide(color: Colors.lightBlueAccent),
                  ),
                  child: const Text('Carrefour'),
                ),
              ],
            ),
            // Mostrar el mensaje de advertencia (si existe)
            if (_mensajeAdvertencia != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _mensajeAdvertencia!,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            // Lista de productos (solo se muestra si la lista no está vacía)
            Expanded(
              child: widget.listaCompra.productos.isEmpty
                  ? Center(child: Text('Tu lista de la compra está vacía.'))
                  : ListView.builder(
                itemCount: widget.listaCompra.productos.length,
                itemBuilder: (context, index) {
                  final producto = widget.listaCompra.productos[index].$1;
                  final cantidad = widget.listaCompra.productos[index].$2;
                  final totalPriceForProduct = listaCompraService.getPrecio(widget.listaCompra, producto);

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Mostrar detalles del producto al hacer clic en la imagen
                          setState(() {
                            _esImagenPulsada = !_esImagenPulsada;
                            _productoSeleccionado = producto;
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
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  if (cantidad > 1) {
                                    setState(() {
                                      listaCompraService.quitarInstancia(widget.listaCompra, producto);
                                      listaCompraService.quitarInstancia(widget.original, producto);
                                      actualizarCantidadController(producto);
                                    });
                                  } else {
                                    _ventanaConfirmacion(context, producto);
                                  }
                                },
                              ),
                              Container(
                                width: 50,
                                child: TextField(
                                  controller: _crearCantidadController(producto),
                                  keyboardType: TextInputType.number,
                                  onChanged: _manejadorTextField,
                                  decoration: InputDecoration(
                                    hintText: cantidad.toString(),
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                  ),
                                  textAlign: TextAlign.center,
                                  onSubmitted: (value) {
                                    int nuevaCantidad = int.tryParse(value) ?? cantidad;
                                    if (nuevaCantidad > 0) {
                                      setState(() {
                                        listaCompraService.setCantidadProducto(widget.listaCompra, producto, nuevaCantidad);
                                        actualizarCantidadController(producto);
                                      });
                                    } else {
                                      _ventanaConfirmacion(context, producto);
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    listaCompraService.annadirInstancia(widget.listaCompra, producto);
                                    actualizarCantidadController(producto);
                                  });
                                },
                              ),
                              Text(
                                '${totalPriceForProduct.toStringAsFixed(2)} €',
                                style: TextStyle(fontSize: 20),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _ventanaConfirmacion(context, producto);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Mostrar el nombre y el precio debajo de la imagen
                      if (_esImagenPulsada && _productoSeleccionado == producto)
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
            // Muestra el precio total de todos los productos
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
                    '${precioTotal.toStringAsFixed(2)} €',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            if (widget.original.productos.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    _mostrarPopUpBolsa(context);
                  },
                  child: Text('Guardar lista'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}