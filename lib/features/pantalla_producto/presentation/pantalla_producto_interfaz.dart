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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                      const SizedBox(width: 10),

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
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

              // Nombre del producto
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Text(
                  producto.nombre,
                  style: const TextStyle(fontFamily: 'Geist', fontSize: 22, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Text(
                  producto.marca,
                  style: const TextStyle(fontFamily: 'Geist', fontSize: 17, color: Colors.black),
                ),
              ),
              const SizedBox(height: 8),

              // Precio y botón de añadir al carrito
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
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
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 20), // Separación aumentada
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
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          precioMedida,
                          style: const TextStyle(fontFamily: 'Geist', fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                    // Botón añadir al carrito
                    GestureDetector(
                      onTap: () async {
                        try {
                          listaCompraService.annadirProducto(listaCompra, producto);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${producto.nombre} añadido a la lista de compra')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error al añadir a la lista de compra')),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.07,
                          vertical: screenHeight * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF95B3FF),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const ImageIcon(
                          AssetImage('assets/icons/cesta_icono.png'),
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // Barra azul de separación
              Container(
                height: 2,
                color: Color(0xFF95B3FF),
              ),
              const SizedBox(height: 50),

              // Productos relacionados
              Text(
                'Productos relacionados',
                style: const TextStyle(fontFamily: 'Geist', fontSize: 20),
              ),
              const SizedBox(height: 16),

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
                                  const SizedBox(height: 4),

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
                                  const SizedBox(height: 8),

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
                                  const SizedBox(height: 4),

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
    // Verificamos si el producto ya está en favoritos al iniciar
    _isFavorito = widget.listaFavoritosService.productoEnFavoritos(widget.listaFavoritos, widget.producto);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          // Si el producto está en favoritos, lo eliminamos
          if (_isFavorito) {
            widget.listaFavoritosService.quitarProducto(widget.listaFavoritos, widget.producto);
          } else {
            // Si el producto no está en favoritos, lo añadimos
            widget.listaFavoritosService.annadirProducto(widget.listaFavoritos, widget.producto);
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