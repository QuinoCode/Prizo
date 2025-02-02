import 'package:flutter/material.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/features/lista_favoritos/application/lista_favoritos_service.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/features/lista_compra/presentation/lista_compra_interfaz.dart';
import 'package:prizo/features/lista_favoritos/presentation/lista_favoritos_interfaz.dart';
import 'package:prizo/shared/database/database_operations.dart';
import 'package:sqflite/sqflite.dart';

class ListaInterfaz extends StatefulWidget {
  ListaInterfaz({super.key});

  @override
  _ListaInterfazState createState() => _ListaInterfazState();
}


class _ListaInterfazState extends State<ListaInterfaz> {
  final ListaCompraService listaCompraService = ListaCompraService();
  final ListaFavoritosService listaFavoritosService = ListaFavoritosService();
  List<Producto> productosCompra = [];
  List<String> productosCompraNombre = [];
  List<Producto> productosFavoritos = [];
  List<String> productosFavoritosNombre = [];
  ListaCompra listaCompra = ListaCompra(
      id: '1', usuario: 'usuario_demo', productos: []);
  ListaFavoritos listaFavoritos = ListaFavoritos(
      id: '1', usuario: 'usuario_demo', productos: []);
  void _navigateToListaFavoritos() async {
    // Espera al resultado de la pantalla secundaria
    bool? changesMade = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaFavoritosInterfaz(
          listaFavoritos: listaFavoritos,
          listaCompra: listaCompra,
          original: listaFavoritos,
        ),
      ),
    );

    // Si hubo cambios, actualiza la interfaz
    if (changesMade ?? false) {
      setState(() {
        // Aquí puedes actualizar las variables que desees
        //_initializeProductosFavoritos();
        //_initializeNombresFavoritos();
      });
    }
  }

  void _navigateToListaCompra() async {
    // Espera al resultado de la pantalla secundaria
    bool? changesMade = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaCompraInterfaz(
          listaCompra: listaCompra,
        ),
      ),
    );

    // Si hubo cambios, actualiza la interfaz
    if (changesMade ?? false) {
      setState(() {
        // Aquí puedes actualizar las variables que desees
        //_initializeProductosCompra();
        //_initializeNombresCompra();
      });
    }
  }
  Widget _buildProductList(String title, VoidCallback onNavigate) {
    return Builder(
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: screenWidth * 0.085,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Icon(Icons.arrow_forward, size: screenWidth * 0.085),
                ],
              ),
              onTap: onNavigate,
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03, // Ajusta el espacio aquí
          ),
          _buildProductList("Lista de compra", _navigateToListaCompra),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03, // Ajusta el espacio aquí
          ),
          _buildProductList("Lista de favoritos", _navigateToListaFavoritos),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ListaInterfaz(),
  ));
}