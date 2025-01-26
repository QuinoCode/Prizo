import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prizo/features/escaner/presentation/interfaz_scanner.dart';
import 'package:prizo/shared/data_entities/DAO/lista_favoritos_DAO.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared//database/database_operations.dart';
import '/features/distancia_tienda/shop_distance.dart';
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
      final String? idListaFavoritos = await listaFavoritosDAO.getIdListaFavoritosPorUsuario('usuario_actual');
      if (idListaFavoritos != null) {
        final productos = await listaFavoritosDAO.getProductosEnOfertaDeFavoritos(idListaFavoritos);
        setState(() {
          productosEnOferta = productos;
          cargandoOfertas = false;
        });
      } else {
        setState(() {
          cargandoOfertas = false;
        });
      }
    } catch (e) {
      print("Error cargando productos en oferta: $e");
      setState(() {
        cargandoOfertas = false;
      });
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
      setState(() {
        cargandoSupermercados = false;
      });
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
      body: SingleChildScrollView(
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
                        fontSize: width * 0.09,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '¿Qué quieres comprar hoy?',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: width * 0.045,
                        color: Color(0xFF504F4F),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.04),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(width * 0.06),
                ),
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/icons/lupa_icono.png'),
                      size: width * 0.06,
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar productos...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Geist',
                            fontSize: width * 0.04,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: width * 0.03),
                        ),
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
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
                          MaterialPageRoute(builder: (context) => ScannerInterface()), // Reemplaza con tu pantalla
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.04),
              Text(
                'Ofertas de la semana',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: width * 0.056,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.01),
              Column(
                children: [
                  if (cargandoOfertas)
                    Center(child: CircularProgressIndicator())
                  else if (productosEnOferta.isEmpty)
                    Center(
                      child: Text(
                        'No hay productos en oferta en tu lista de favoritos.',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: width * 0.04,
                          color: Colors.grey,
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
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(width * 0.03),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: width * 0.02,
                                    offset: Offset(0, height * 0.005),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      producto.foto,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.01),
                                  Text(
                                    producto.nombre,
                                    style: TextStyle(
                                      fontFamily: 'Geist',
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$${producto.precioOferta.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontFamily: 'Geist',
                                      fontSize: width * 0.04,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
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
                            color: currentIndex == index ? Colors.blue : Colors.grey,
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
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.bold,
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
                      : Colors.grey[300],
                  child: Text(
                    day,
                    style: TextStyle(
                      color: day == currentDay[0].toUpperCase()
                          ? Colors.black
                          : Colors.black,
                      fontFamily: 'Geist',
                    ),
                  ),
                ))
                    .toList(),
              ),
              SizedBox(height: height * 0.04),
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
                      '¡Recuerda llevarte tu bolsa\nde tela!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: width * 0.046,
                        color: Color(0xFF504F4F),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
              Text(
                'Tus supermercados cercanos',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: width * 0.055,
                  fontWeight: FontWeight.bold,
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
                    fontSize: width * 0.04,
                    color: Colors.grey,
                  ),
                ),
              )
                  : Container(
                height: height * 0.24, // Altura de los items, ajusta como desees
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

                    final String calle = partesDireccion.isNotEmpty ? partesDireccion[1] : "Calle no disponible";

                    final String numero = partesDireccion.length > 1 ? partesDireccion[2].trim() : "Número no disponible";

                    final String calleYNumero = "$calle, $numero";

                    return Padding(
                      padding: EdgeInsets.only(right: width * 0.03),  // Separación horizontal entre los items
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,  // Centra los elementos en el eje vertical de la fila
                        children: [
                          // Contenedor para el logo y el texto
                          Container(
                            width: width * 0.6,  // Ancho fijo para cada item
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,  // Centra los elementos verticalmente dentro del contenedor
                              crossAxisAlignment: CrossAxisAlignment.center,  // Asegura que los elementos estén alineados al centro horizontalmente
                              children: [
                                // Logo con tamaño fijo
                                Image.asset(
                                  logo,
                                  width: width * 0.3,  // Tamaño fijo para todos los logos
                                  height: width * 0.3,  // Asegura que todos los logos tengan la misma altura
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: height * 0.01),  // Espacio entre el logo y el texto
                                // Row para alinear la distancia y dirección a la izquierda
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,  // Alinea los textos a la izquierda
                                  children: [
                                    // Distancia
                                    Text(
                                      "A $distancia km",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: 'Geist',
                                        fontSize: width * 0.050,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: height * 0.01),  // Espacio entre distancia y dirección
                                    // Dirección
                                    Text(
                                      calleYNumero,
                                      style: TextStyle(
                                        fontFamily: 'Geist',
                                        fontSize: width * 0.035,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,  // Agrega "..." si el texto es muy largo
                                      maxLines: 2,  // Limita el número de líneas
                                      textAlign: TextAlign.left,  // Alinea la dirección a la izquierda
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Barra azul vertical
                          Container(
                            width: 2.0,  // Ancho de la barra azul
                            height: height * 0.12,  // Ajusta la altura de la barra
                            color: Color(0xFF95B3FF),  // Color azul
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
    );
  }
}