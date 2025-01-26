import 'package:flutter/material.dart';
import '../../../shared/data_entities/models/producto.dart';
import '../../lista_compra/application/lista_compra_service.dart';
import '../../lista_favoritos/application/lista_favoritos_service.dart';
import '../../../shared/data_entities/models/lista_compra.dart';
import '../../../shared/data_entities/models/lista_favoritos.dart';
import '../../pantalla_producto/application/pantalla_producto_service.dart';
import '../../distancia_tienda/shop_distance.dart';

class DetallesProducto extends StatelessWidget {
  final Producto producto;
  final ListaCompraService listaCompraService = ListaCompraService();
  final ListaFavoritosService listaFavoritosService = ListaFavoritosService();
  final ListaCompra listaCompra;
  final ListaFavoritos listaFavoritos;
  final PantallaProductoService pantallaProductoService = PantallaProductoService();
  final ShopDistance shopDistance = ShopDistance();

  DetallesProducto({
    Key? key,
    required this.producto,
    required this.listaCompra,
    required this.listaFavoritos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener tamaño de pantalla
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final imageUrl = producto.foto;
    final precioMedida = producto.precioMedida > 0 ? '${producto.precioMedida.toStringAsFixed(2)}€/kg' : '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/icons/arrow.png',
            width: 24,
            height: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.02),
                    child: SizedBox(
                      width: screenWidth * 0.2,
                      height: screenWidth * 0.2,
                      child: pantallaProductoService.obtenerLogoSupermercado(producto),
                    ),
                  ),
                  Row(
                    children: [
                      // Botón de distancia
                      BotonDistancia(
                        onTap: () async {
                          try {
                            shopDistance.launchMapQuery(producto.tienda);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al mostrar el mapa')),
                            );
                          }
                        },
                      ),
                      SizedBox(width: screenWidth * 0.03),

                      // Botón de favoritos
                      BotonFavoritos(
                        producto: producto,
                        listaFavoritos: listaFavoritos,
                        listaFavoritosService: listaFavoritosService,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),

              // Imagen del producto
              Center(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: screenWidth * 0.6,
                  height: screenWidth * 0.6,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 100);
                  },
                )
                    : const Icon(Icons.image_not_supported, size: 100),
              ),
              SizedBox(height: screenHeight * 0.01),

              // Nombre del producto
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Text(
                  producto.nombre,
                  style: const TextStyle(fontFamily: 'Geist', fontSize: 24, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Text(
                  producto.marca,
                  style: const TextStyle(fontFamily: 'Geist', fontSize: 17, color: Colors.black),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Precio y botón de añadir al carrito
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mostrar precio con descuento si está en oferta
                        if (producto.oferta)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic, // Alineación precisa
                            children: [
                              Text(
                                '${producto.precioOferta.toStringAsFixed(2)}€',
                                style: const TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.05), // Separación aumentada
                              Text(
                                '${producto.precio.toStringAsFixed(2)}€',
                                style: const TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 20,
                                  color: Colors.black,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          )
                        else
                        // Mostrar precio normal si no está en oferta
                          Text(
                            '${producto.precio.toStringAsFixed(2)}€',
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          precioMedida,
                          style: const TextStyle(fontFamily: 'Geist', fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                    // Botón añadir al carrito
                    BotonCarrito(
                      producto: producto,
                      listaCompraService: listaCompraService,
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Barra azul de separación
              Container(
                height: 2,
                color: const Color(0xFF95B3FF),
              ),
              SizedBox(height: screenHeight * 0.05),

              // Productos relacionados
              Text(
                'Productos relacionados',
                style: const TextStyle(fontFamily: 'Geist', fontSize: 20),
              ),
              SizedBox(height: screenHeight * 0.02),

              // FutureBuilder para mostrar productos relacionados
              FutureBuilder<List<Producto>>(
                future: pantallaProductoService.obtenerProductosSimilares(
                    PantallaProductoService.limpiarNombreProducto(producto.nombre), producto),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar productos relacionados.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay productos relacionados.'));
                  } else {
                    List<Producto> productosRelacionados = snapshot.data!;
                    return SizedBox(
                      height: screenHeight * 0.25,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: productosRelacionados.length,
                        itemBuilder: (context, index) {
                          Producto productoRelacionado = productosRelacionados[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetallesProducto(
                                    producto: productoRelacionado,
                                    listaCompra: listaCompra,
                                    listaFavoritos: listaFavoritos,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: screenWidth * 0.04),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Alinear a la izquierda
                                children: [
                                  SizedBox(
                                    width: screenWidth * 0.1,
                                    child: pantallaProductoService.obtenerLogoSupermercado(productoRelacionado),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),

                                  // Imagen del producto
                                  Image.network(
                                    productoRelacionado.foto,
                                    width: screenWidth * 0.2,
                                    height: screenWidth * 0.2,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image, size: 60);
                                    },
                                  ),
                                  SizedBox(height: screenHeight * 0.01),

                                  // Nombre del producto
                                  SizedBox(
                                    width: screenWidth * 0.24,
                                    child: Text(
                                      productoRelacionado.nombre,
                                      style: const TextStyle(fontFamily: 'Geist', fontSize: 10),
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),

                                  // Precio del producto
                                  Text(
                                    '${productoRelacionado.precio.toStringAsFixed(2)}€',
                                    style: const TextStyle(fontFamily: 'Geist', fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BotonFavoritos extends StatefulWidget {
  final Producto producto;
  final ListaFavoritos listaFavoritos;
  final ListaFavoritosService listaFavoritosService;

  const BotonFavoritos({
    Key? key,
    required this.producto,
    required this.listaFavoritos,
    required this.listaFavoritosService,
  }) : super(key: key);

  @override
  _BotonFavoritosState createState() => _BotonFavoritosState();
}

class _BotonFavoritosState extends State<BotonFavoritos> {
  late bool _isFavorito;

  @override
  void initState() {
    super.initState();
    // Usamos addPostFrameCallback para esperar al siguiente ciclo de renderizado
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _verificarFavorito();
    });
  }

  // Función asincrónica para verificar si el producto está en favoritos
  Future<void> _verificarFavorito() async {
    bool isFavorito = await widget.listaFavoritosService.isProductoEnFavoritos(widget.producto);
    setState(() {
      _isFavorito = isFavorito;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          // Si el producto está en favoritos, lo eliminamos
          if (_isFavorito) {
            widget.listaFavoritosService.DB_quitarProducto(widget.producto);
          } else {
            // Si el producto no está en favoritos, lo añadimos
            widget.listaFavoritosService.DB_annadirProducto(widget.producto);
          }

          // Cambiar el estado de favorito
          _isFavorito = !_isFavorito;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF95B3FF),
        ),
        child: Center(
          child: ImageIcon(
            AssetImage(
              _isFavorito
                  ? 'assets/icons/corazonnegro_icono.png'  // Ícono cuando está en favoritos
                  : 'assets/icons/corazon_icono.png',  // Ícono cuando no está en favoritos
            ),
            size: 24,
          ),
        ),
      ),
    );
  }
}

class BotonDistancia extends StatefulWidget {
  final Function onTap;

  const BotonDistancia({Key? key, required this.onTap}) : super(key: key);

  @override
  _BotonDistanciaState createState() => _BotonDistanciaState();
}

class _BotonDistanciaState extends State<BotonDistancia> {
  Color _color = Color(0xFF95B3FF); // Color original

  // Cambiar color cuando el botón es presionado
  void _onTapDown(TapDownDetails details) {
    setState(() {
      _color = Colors.grey; // Cambia al color que quieras cuando se presiona
    });
  }

  // Volver al color original cuando se suelta el botón
  void _onTapUp(TapUpDetails details) {
    setState(() {
      _color = Color(0xFF95B3FF); // Color original al soltar
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown, // Detectar cuando se presiona
      onTapUp: _onTapUp, // Detectar cuando se suelta
      onTap: () {
        widget.onTap();  // Llamar al onTap pasado desde el widget principal
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _color,
        ),
        child: const Icon(Icons.map_outlined, color: Colors.black),
      ),
    );
  }
}

class BotonCarrito extends StatefulWidget {
  final Producto producto;
  final ListaCompraService listaCompraService;

  const BotonCarrito({
    Key? key,
    required this.producto,
    required this.listaCompraService,
  }) : super(key: key);

  @override
  _BotonCarritoState createState() => _BotonCarritoState();
}

class _BotonCarritoState extends State<BotonCarrito> {
  int _counter = 0;
  bool _showButton = true; // Siempre empezamos con el botón visible

  @override
  void initState() {
    super.initState();
    _initializeState(); // Inicializamos el estado, pero no mostramos el contador aún
  }

  // Este método inicializa el estado, pero el contador solo aparecerá cuando se haga clic en el botón
  Future<void> _initializeState() async {
    final cantidad = await widget.listaCompraService.DB_fetchCantidad(widget.producto);
    setState(() {
      // No cambiamos _showButton aquí, lo dejamos en true para que siempre empiece con el botón
      _counter = cantidad;
    });
  }

  void _addToCart() async {
    // Añadimos el producto al carrito
    widget.listaCompraService.DB_annadirProducto(widget.producto);
    final cantidad = await widget.listaCompraService.DB_fetchCantidad(widget.producto);
    setState(() {
      _counter = cantidad;
      _showButton = false; // El botón cambia para mostrar el contador
    });
  }

  void _incrementCounter() async {
    if (_counter < widget.listaCompraService.LIMITE) {
      widget.listaCompraService.DB_increaseCantidad(widget.producto);
      final cantidad = await widget.listaCompraService.DB_fetchCantidad(widget.producto);
      setState(() {
        _counter = cantidad;
      });
    }
  }

  void _decrementCounter() async {
    if (_counter > 1) {
      widget.listaCompraService.DB_decreaseCantidad(widget.producto);
      final cantidad = await widget.listaCompraService.DB_fetchCantidad(widget.producto);
      setState(() {
        _counter = cantidad;
      });
    } else {
      widget.listaCompraService.DB_quitarProducto(widget.producto);
      setState(() {
        _counter = 0;
        _showButton = true; // El botón vuelve a aparecer y el contador se reinicia
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showButton
        ? Container(
      height: MediaQuery.of(context).size.height * 0.0473,
      width: MediaQuery.of(context).size.width * 0.21,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 149, 179, 252),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: _addToCart,
        color: const Color.fromARGB(255, 80, 79, 79),
        icon: ImageIcon(
          const AssetImage('assets/icons/shopping_basket.png'),
          size: MediaQuery.of(context).size.width * 0.0615,
          color: const Color.fromARGB(255, 18, 18, 18),
        ),
      ),
    )
        : Container(
      height: MediaQuery.of(context).size.height * 0.0473,
      width: MediaQuery.of(context).size.width * 0.21,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 246, 246, 246),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Botón para decrementar
          Positioned(
            top: 0,
            bottom: 0,
            right: MediaQuery.of(context).size.width * 0.095,
            child: IconButton(
              iconSize: MediaQuery.of(context).size.width * 0.06,
              padding: EdgeInsets.zero,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: const Icon(Icons.remove),
              onPressed: _decrementCounter,
            ),
          ),
          // Contador centrado
          Positioned(
            left: MediaQuery.of(context).size.width * 0.089,
            top: MediaQuery.of(context).size.height * 0.004,
            bottom: 0,
            child: Text(
              '$_counter',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.0615,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // Botón para incrementar
          Positioned(
            top: 0,
            bottom: MediaQuery.of(context).size.height * 0.001,
            left: MediaQuery.of(context).size.width * 0.093,
            child: IconButton(
              padding: EdgeInsets.zero,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(
                Icons.add,
                size: MediaQuery.of(context).size.width * 0.06,
              ),
              onPressed: _incrementCounter,
            ),
          ),
        ],
      ),
    );
  }
}