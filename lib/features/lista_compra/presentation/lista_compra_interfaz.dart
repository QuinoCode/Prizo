import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/shared/application/producto_service.dart';
import 'package:prizo/shared/database/database_operations.dart';

class ListaCompraInterfaz extends StatefulWidget {
  final ListaCompra listaCompra;

  ListaCompraInterfaz({super.key, required this.listaCompra});

  @override
  _ListaCompraInterfazState createState() => _ListaCompraInterfazState();
}

class _ListaCompraInterfazState extends State<ListaCompraInterfaz> {

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

  Widget _buildListViewTile(BuildContext context, Producto producto){
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _navigateToProductInfo(widget.producto),
                child: Image.network(
                  widget.producto.foto,
                  width: MediaQuery.of(context).size.width * 0.222,
                  height: MediaQuery.of(context).size.width * 0.222,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.028), 
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.119,
                child: VerticalDivider(
                  thickness: 1,
                  color: Color.fromARGB(255,175,198,255),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.028), 
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _navigateToProductInfo(widget.producto);
                  },
                  child:
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3352,
                          child:
                            Text(
                              widget.producto.nombre,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color.fromARGB(255,33,33,33),
                                    fontSize: MediaQuery.of(context).size.width * 0.0419,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                            )
                        ),
                        SizedBox(height: MediaQuery.of(context).size.width * 0.0104),
                        Text(
                          widget.producto.tienda,
                          style: TextStyle(
                                fontFamily: 'Inter',
                                color: Color.fromARGB(255,33,33,33),
                                fontSize: MediaQuery.of(context).size.width * 0.0332,
                                letterSpacing: 0.0,
                              ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.width * 0.023),
                        Text(
                          '${widget.producto.precio}€',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              color: Color.fromARGB(255,33,33,33),
                              fontSize: MediaQuery.of(context).size.width * 0.0448,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                        ),
                      ],
                    ),
                )
              ),
                SizedBox(
                  child: Column (
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.047,
                        width: MediaQuery.of(context).size.width * 0.18,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 240, 240, 240),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              bottom: 0,
                              right: MediaQuery.of(context).size.width * 0.07,
                              child: IconButton(
                                iconSize: MediaQuery.of(context).size.width * 0.053,
                                padding: EdgeInsets.zero,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,  
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (_counter > 0) {
                                      DatabaseOperations.instance.decreaseCantidadListaCompra(db, widget.producto);
                                      _counter--;
                                    } else {
                                      DatabaseOperations.instance.deleteFromListaCompraTable(db, widget.producto);
                                      _showButton = true;
                                    }
                                  });
                                },
                              ),
                            ),
                            _counter < 10 
                            ? Positioned(
                                left: MediaQuery.of(context).size.width * 0.074,
                                top: MediaQuery.of(context).size.height * 0.0055,
                                bottom: 0,
                                child: Text('$_counter', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.053, fontWeight: FontWeight.w500)),
                              )
                            : Positioned(
                                left: MediaQuery.of(context).size.width * 0.063,
                                top: MediaQuery.of(context).size.height * 0.008,
                                bottom: 0,
                                child: Text('$_counter', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.0448, fontWeight: FontWeight.w500)),
                              ),
                            Positioned(
                              top: 0,
                              bottom: 0,
                              left: MediaQuery.of(context).size.width * 0.070,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,  
                                iconSize: MediaQuery.of(context).size.width * 0.053,
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  if (_counter < 99) {
                                    DatabaseOperations.instance.increaseCantidadListaCompra(db, widget.producto);
                                    setState(() {
                                      _counter++;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  )
                )
            ],
          ),
        ),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _toggleTienda("Dia"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tiendasSeleccionadas.contains("Dia") ? Color(0xFF95B3FF) : Colors.white,
                  side: BorderSide(color: Color(0xFF95B3FF)),
                ),
                child: const Text('Día'),
              ),
              ElevatedButton(
                onPressed: () => _toggleTienda("Consum"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tiendasSeleccionadas.contains("Consum") ? Color(0xFF95B3FF) : Colors.white,
                  side: BorderSide(color: Color(0xFF95B3FF)),
                ),
                child: const Text('Consum'),
              ),
              ElevatedButton(
                onPressed: () => _toggleTienda("Carrefour"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tiendasSeleccionadas.contains("Carrefour") ? Color(0xFF95B3FF) : Colors.white,
                  side: BorderSide(color: Color(0xFF95B3FF)),
                ),
                child: const Text('Carrefour'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the first list of products
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _productos.length,
                    itemBuilder: (context, index) {
                      final producto = _productos[index];
                      return _buildListViewTile(context, producto);
                    },
                  ),
                ]
              )
            )
          )
        ]
      )
      )
    );
  }
}
