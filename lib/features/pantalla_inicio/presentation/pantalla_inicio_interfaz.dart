import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prizo/features/escaner/presentation/interfaz_scanner.dart';
import 'package:prizo/features/pantalla_producto/presentation/pantalla_producto_interfaz.dart';
import 'package:prizo/main.dart';
import 'package:prizo/shared/data_entities/DAO/lista_favoritos_DAO.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/shared//database/database_operations.dart';
import 'package:provider/provider.dart';
import 'package:prizo/features/distancia_tienda/shop_distance.dart';
import 'package:prizo/features/lista_favoritos/application/lista_favoritos_service.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class PantallaInicio extends StatefulWidget {
  @override
  _PantallaInicioState createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  final ListaFavoritosDAO listaFavoritosDAO = ListaFavoritosDAO(DatabaseOperations.instance.prizoDatabase);
  final ListaFavoritosService listaFavoritosService = new ListaFavoritosService();
  List<Producto> productosEnOferta = [];
  bool cargandoOfertas = true;

  // Variables para lógica supermercados cercanos
  List<Map<String, dynamic>> supermercadosCercanos = [];
  bool cargandoSupermercados = true;
  final shopDistance = ShopDistance();

  @override
  void initState() {
    super.initState();
    cargarProductosEnOferta();
    cargarSupermercadosCercanos();
  }

  Future<void> cargarProductosEnOferta() async {
    try {
      // Obtener los productos de la lista de favoritos
      List<Producto> productosFavoritos = await listaFavoritosService.DB_fetchProducts();

      // Filtrar productos que están en oferta (se asume que el atributo es bool oferta)
      List<Producto> productosFiltrados = productosFavoritos.where((producto) {
        return producto.oferta; // Solo seleccionamos productos con el atributo 'oferta' en true
      }).toList();

      setState(() {
        productosEnOferta = productosFiltrados;
        cargandoOfertas = false;
      });
    } catch (e) {
      print("Error cargando productos en oferta: $e");
      if (mounted){
        setState(() {
          cargandoOfertas = false;
        });
      }
    }
  }

  Future<void> cargarSupermercadosCercanos() async {
    try {
      setState(() {
        cargandoSupermercados = true;
      });

      // Obtener las coordenadas actuales
      final coords = await shopDistance.location.getLocation();

      // Construir la URL para la solicitud
      final url = shopDistance.getFullUri(coords, "supermercado");

      // Llamar a la API
      final response = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body);
        final List<dynamic> items = jsonMap["items"];

        // Filtrar resultados por nombre específico o categoría "Supermercado"
        final List<Map<String, dynamic>> filteredSupermarkets = items.where((item) {
          final title = item["title"]?.toString().toLowerCase() ?? "";
          final categories = item["categories"] as List<dynamic>? ?? [];

          // Verificar si el título contiene "Dia", "Consum" o "Carrefour"
          final matchesName = title.contains("dia") ||
              title.contains("consum") ||
              title.contains("carrefour");

          // Verificar si pertenece a la categoría "Supermercado"
          final isSupermarket = categories.any((category) =>
          category["name"].toString().toLowerCase() == "supermercado" &&
              category["primary"] == true);

          return matchesName && isSupermarket;
        }).map((item) {
          return Map<String, dynamic>.from(item);
        }).toList();

        // Actualizar el estado con los supermercados filtrados
        setState(() {
          supermercadosCercanos = filteredSupermarkets;
          cargandoSupermercados = false;
        });
      } else {
        throw Exception("Error en la API: ${response.statusCode}");
      }
    } catch (e) {
      print("Error cargando supermercados cercanos: $e");
      if (mounted){
        setState(() {
          cargandoSupermercados = false;
        });
      }
    }
  }

  String obtenerLogoSupermercado(String? nombreSupermercado) {
    // Definir una lógica para obtener el logo según el nombre del supermercado
    if (nombreSupermercado != null) {
      if (nombreSupermercado.toLowerCase().contains('dia')) {
        return 'assets/images/logo_dia.png';
      } else if (nombreSupermercado.toLowerCase().contains('consum')) {
        return 'assets/images/logo_consum.png';
      } else if (nombreSupermercado.toLowerCase().contains('carrefour')) {
        return 'assets/images/logo_carrefour.png';
      }
    }
    // Si no se encuentra un logo, devolver uno por defecto
    return 'assets/logos/logo_default.png';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final String currentDay = DateFormat.EEEE('es_ES').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(backgroundColor:
    Colors.white,
      toolbarHeight: MediaQuery.of(context).size.longestSide * 0.002,),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.05),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'PRIZO',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: width * 0.0966,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '¿Qué quieres comprar hoy?',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: width * 0.04293,
                          color: Color(0xFF504F4F),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.04),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(width * 0.06),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.shortestSide * 0.049),
                      ImageIcon(
                        AssetImage('assets/icons/lupa_icono.png'),
                        size: width * 0.06,
                      ),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar productos...',
                            hintStyle: TextStyle(
                              color: Color(0xFF504F4F),
                              fontFamily: 'Geist',
                              fontSize: width * 0.04293,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: width * 0.03),
                          ),
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: width * 0.04293,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF121212),
                          ),
                          onSubmitted: (query) {
                            Provider.of<PrizoState>(context, listen: false).setIndex(1, query);
                          },
                        ),
                      ),
                      IconButton(
                        icon: ImageIcon(
                          AssetImage('assets/icons/escaner_icono.png'),
                          size: width * 0.06,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ScannerInterface()),
                          );
                        },
                      ),
                      SizedBox(width: MediaQuery.of(context).size.shortestSide * 0.0245),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.04),
                Text(
                  'Ofertas de la semana',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: MediaQuery.of(context).size.shortestSide * 0.0644,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: height * 0.01),
                Column(
                  children: [
                    if (cargandoOfertas)
                      SizedBox(
                          height: height * 0.264,
                          child: Center(child: CircularProgressIndicator(color: Color(0xFF95B3FF), ))
                      )
                    else if (productosEnOferta.isEmpty)
                      SizedBox(
                        height: height * 0.264,
                        child: Center(
                          child: Column(
                            children: [
                            Padding(
                              padding:  EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
                              child: Image.asset('assets/images/sin_ofertas.png', height:height * 0.175 ,),
                            ),
                              Padding(
                                padding:  EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.030),
                                child: Text(
                                  'Ninguno de tus favoritos está\nen oferta',
                                  style: TextStyle(
                                    fontFamily: 'Geist',
                                    fontSize: width * 0.04293,
                                    color: Color(0xFF504F4F),
                                  ),
                                textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        height: height * 0.25,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: productosEnOferta.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final producto = productosEnOferta[index];
                            ListaCompra listaCompra = ListaCompra(
                                id: '1', usuario: 'usuario_demo', productos: []);
                            ListaFavoritos listaFavoritos = ListaFavoritos(
                                id: '1', usuario: 'usuario_demo', productos: []);

                            // Calcular el porcentaje de descuento
                            double descuento = ((producto.precio - producto.precioOferta) / producto.precio) * 100;
                            String descuentoTexto = descuento.toStringAsFixed(0) + '%';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetallesProducto(producto: producto, listaCompra: listaCompra, listaFavoritos: listaFavoritos),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(width * 0.03),
                                  ),
                                  child: Row(
                                    children: [
                                      // Imagen del producto
                                      Container(
                                        width: width * 0.4,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(width * 0.03),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(width * 0.03),
                                          child: Image.network(
                                            producto.foto,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) =>
                                              Image.asset(
                                                'assets/images/placeholder.png',
                                                fit: BoxFit.contain,
                                              )
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: width * 0.07),  // Espacio entre la imagen y el texto

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Nombre del producto
                                            SizedBox(height: height * 0.04),
                                            Text(
                                              producto.nombre,
                                              style: TextStyle(
                                                fontFamily: 'Geist',
                                                fontSize: width * 0.04293,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              overflow: TextOverflow.ellipsis, // Para cortar el nombre largo
                                              maxLines: 4,
                                            ),
                                            SizedBox(height: height * 0.02),  // Espacio entre el nombre y el precio

                                            // Precio del producto
                                            Text(
                                                '-$descuentoTexto',
                                                style: TextStyle(
                                                fontFamily: 'Geist',
                                                fontSize: width * 0.0966,
                                                color: Color(0xFF121212),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: height * 0.02),
                    if (productosEnOferta.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          productosEnOferta.length,
                              (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                            width: currentIndex == index ? width * 0.03 : width * 0.02,
                            height: currentIndex == index ? width * 0.03 : width * 0.02,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentIndex == index ? Color(0xFF121212) :Color(0xFFD9D9D9),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: height * 0.03),
                Divider(color: Color(0xFF95B3FF), thickness: height * 0.002),
                SizedBox(height: height * 0.03),
                Center(
                  child: Text(
                    '¡Hoy es $currentDay de compra!',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: width * 0.04293,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                      .map((day) => CircleAvatar(
                    backgroundColor: day == currentDay[0].toUpperCase()
                        ? Color(0xFF95B3FF)
                        : Color(0xFFF6F6F6),
                    child: Text(
                      day,
                      style: TextStyle(
                        color: day == currentDay[0].toUpperCase()
                            ? Color(0xFF121212)
                            : Color(0xFF121212),
                        fontFamily: 'Geist',
                      ),
                    ),
                  ))
                      .toList(),
                ),
                SizedBox(height: height * 0.03),
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/Bolsa_de_tela.png',
                        width: width * 0.5,
                        height: height * 0.25,
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        '¡Recuerda llevarte tu\nbolsa de tela!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: width * 0.04293,
                          color: Color(0xFF504F4F),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.03),
                Divider(color: Color(0xFF95B3FF), thickness: height * 0.002),
                SizedBox(height: height * 0.03),
                Text(
                  'Tus supermercados cercanos',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: width * 0.0644,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: height * 0.02),
                cargandoSupermercados
                    ? Center(child: CircularProgressIndicator())
                    : supermercadosCercanos.isEmpty
                    ? Center(
                  child: Text(
                    'No se encontraron supermercados cercanos.',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: width * 0.04293,
                      color: Color(0xFF504F4F),
                    ),
                  ),
                )
                    : SizedBox(
                  height: height * 0.24,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: supermercadosCercanos.length,
                    itemBuilder: (context, index) {
                      final supermercado = supermercadosCercanos[index];

                      // Obtener el título de forma segura
                      final String title = supermercado["title"] is String ? supermercado["title"] : "Supermercado Desconocido";

                      // Obtener el logo
                      final logo = obtenerLogoSupermercado(title);

                      // Obtener la distancia
                      final distancia = (supermercado["distance"] / 1000).toStringAsFixed(2);

                      final String direccionCompleta = supermercado["address"]?["label"] ?? "Dirección no disponible";

                      final direccionCorregida = utf8.decode(latin1.encode(direccionCompleta));

                      final List<String> partesDireccion = direccionCorregida.split(',');

                      final String calle = partesDireccion.isNotEmpty ? partesDireccion[1].trim() : "Calle no disponible";

                      final String numero = partesDireccion.length > 1 ? partesDireccion[2].trim() : "Número no disponible";

                      final String calleYNumero = "$calle, $numero";

                      return Padding(
                        padding: EdgeInsets.only(right: width * 0.03),  // Separación horizontal entre los items
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: width * 0.6,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Logo con tamaño fijo
                                  Image.asset(
                                    logo,
                                    width: width * 0.3,
                                    height: width * 0.3,
                                    fit: BoxFit.contain,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,  // Alinea los textos a la izquierda
                                    children: [
                                      // Distancia
                                      Text(
                                        "A $distancia km",
                                        style: TextStyle(
                                          fontFamily: 'Geist',
                                          fontSize: width * 0.0533,
                                          color: Color(0xFF121212),
                                        ),
                                      ),
                                      // Dirección
                                      Text(
                                        calleYNumero,
                                        style: TextStyle(
                                          fontFamily: 'Geist',
                                          fontSize: width * 0.04293,
                                          color: Color(0xFF121212),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Barra azul vertical
                            Container(
                              width: MediaQuery.of(context).size.shortestSide * 0.005,
                              height: height * 0.12,
                              color: Color(0xFF95B3FF),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: height * 0.1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
