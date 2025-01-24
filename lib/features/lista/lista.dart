import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/features/lista_compra/presentation/lista_compra_interfaz.dart';
import 'package:prizo/features/lista_favoritos/application/lista_favoritos_service.dart';
import 'package:prizo/features/lista_favoritos/presentation/lista_favoritos_interfaz.dart';

class ListaInterfaz extends StatefulWidget {
  ListaInterfaz({super.key});

  @override
  _ListaInterfazState createState() => _ListaInterfazState();
}

class _ListaInterfazState extends State<ListaInterfaz> {
  final ListaCompraService listaCompraService = ListaCompraService();
  final ListaFavoritosService listaFavoritosService = ListaFavoritosService();
  ListaCompra listaCompra = ListaCompra(
      id: '1', usuario: 'usuario_demo', productos: []);
  ListaFavoritos listaFavoritos = ListaFavoritos(
      id: '1', usuario: 'usuario_demo', productos: []);

  @override
  void initState() {
    super.initState();
    _initializeListaFavoritos();
    _initializeListaCompra();
  }
  void _initializeListaFavoritos() async {
    // Llama a generar_ListaFavoritos y espera el resultado
    ListaFavoritos fetchedListaFavoritos = await listaFavoritosService.generar_ListaFavoritos();

    // Actualiza el estado con los datos obtenidos
    setState(() {
      listaFavoritos = fetchedListaFavoritos;
    });
  }
  void _initializeListaCompra() async {
    // Llama a generar_ListaCompra y espera el resultado
    ListaCompra fetchedListaCompra = await listaCompraService.generar_ListaCompra();

    // Actualiza el estado con los datos obtenidos
    setState(() {
      listaCompra = fetchedListaCompra;
    });
  }

  void _navigateToListaCompra() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ListaCompraInterfaz(
              listaCompra: listaCompra,
            ),
      ),
    );
  }

  void _navigateToListaFavoritos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ListaFavoritosInterfaz(
              listaFavoritos: listaFavoritos,
              listaCompra: listaCompra,
              original: listaFavoritos,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Listas"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Lista de la compra"),
            trailing: const Icon(Icons.arrow_forward),
            onTap: _navigateToListaCompra,
          ),
          const Divider(),
          ListTile(
            title: const Text("Lista de favoritos"),
            trailing: const Icon(Icons.arrow_forward),
            onTap: _navigateToListaFavoritos,
          ),
        ],
      ),
    );
  }
}