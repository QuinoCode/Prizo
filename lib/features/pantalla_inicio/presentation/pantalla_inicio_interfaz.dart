import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prizo/shared/data_entities/DAO/lista_favoritos_DAO.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared//database/database_operations.dart';


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

  @override
  void initState() {
    super.initState();
    cargarProductosEnOferta();
  }

  Future<void> cargarProductosEnOferta() async {
    try {
      // Obtén el ID de la lista de favoritos
      final String? idListaFavoritos = await listaFavoritosDAO.getIdListaFavoritosPorUsuario('usuario_actual');
      if (idListaFavoritos != null) {
        // Obtén los productos en oferta de esa lista
        final productos = await listaFavoritosDAO.getProductosEnOfertaDeFavoritos(idListaFavoritos);
        setState(() {
          productosEnOferta = productos;
          cargandoOfertas = false; // Datos cargados
        });
      } else {
        // Si no hay lista de favoritos
        setState(() {
          cargandoOfertas = false; // No hay nada que mostrar
        });
      }
    } catch (e) {
      print("Error cargando productos en oferta: $e");
      setState(() {
        cargandoOfertas = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentDay = DateFormat.EEEE('es_ES').format(DateTime.now());

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Text(
                      'PRIZO',
                      style: TextStyle(fontFamily: 'Kanit', fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '¿Qué quieres comprar hoy?',
                      style: TextStyle(fontFamily: 'Geist', fontSize: 16, color: Color(0xFF504F4F)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/icons/lupa_icono.png'),
                      size: 22,
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar productos...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Geist',
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 14),
                        ),
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: ImageIcon(
                        AssetImage('assets/icons/escaner_icono.png'),
                        size: 22,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Ofertas de la semana',
                style: TextStyle(fontFamily: 'Geist', fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  if (cargandoOfertas) // Muestra un indicador de carga
                    Center(child: CircularProgressIndicator())
                  else if (productosEnOferta.isEmpty) // Si no hay productos en oferta
                    Center(
                      child: Text(
                        'No hay productos en oferta en tu lista de favoritos.',
                        style: TextStyle(fontFamily: 'Geist', fontSize: 16, color: Colors.grey),
                      ),
                    )
                  else
                    Container(
                      height: 200, // Altura para productos más grandes
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
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
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
                                  SizedBox(height: 8),
                                  Text(
                                    producto.nombre,
                                    style: TextStyle(fontFamily: 'Geist', fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '\$${producto.precioOferta.toStringAsFixed(2)}',
                                    style: TextStyle(fontFamily: 'Geist', fontSize: 14, color: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 10),
                  if (productosEnOferta.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        productosEnOferta.length,
                            (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: currentIndex == index ? 12 : 8,
                          height: currentIndex == index ? 12 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentIndex == index ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20),
              Divider(color: Color(0xFF95B3FF)),
              SizedBox(height: 20),
              Center(
                child: Text(
                  '¡Hoy es $currentDay de compra!',
                  style: TextStyle(fontFamily: 'Geist', fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
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
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ))
                    .toList(),
              ),
              SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/Bolsa_de_tela.png',
                      width: 200,
                      height: 200,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '¡Recuerda llevarte tu bolsa\nde tela!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Geist', fontSize: 18, color: Color(0xFF504F4F)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Tus supermercados cercanos',
                style: TextStyle(fontFamily: 'Geist', fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                height: 120, // Altura para lista horizontal
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // Número de supermercados
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.store, color: Colors.white),
                        ),
                        title: Text('Supermercado ${index + 1}'),
                        subtitle: Text('Distancia: ${index * 0.5 + 0.3} km\nDirección: Calle Falsa ${index + 123}'),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 80, // Espacio para la barra de navegación flotante
              ),
            ],
          ),
        ),
      ),
    );
  }
}