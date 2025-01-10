import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
//import '/features/pantalla_inicio/presentation/pantalla_inicio_interfaz.dart';
//import '/features/productsearch/productsearch.ui.dart';
import 'package:prizo/features/productsearch/productsearch.ui.dart';
import 'package:prizo/features/perfil/perfil.dart';
import 'package:prizo/shared/application/icon_service.dart';

class BarraNavegacion extends StatefulWidget {
  @override
  _BarraNavegacionState createState() => _BarraNavegacionState();
}

class _BarraNavegacionState extends State<BarraNavegacion> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ProductSearchScreen(),
    ProductSearchScreen(),
    PerfilInterfaz(),
    PerfilInterfaz(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _screens[_currentIndex],
          ),


          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              height: 63,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30), // Forma ovalada
                border: Border.all(
                  color: Color(0xFF95B3FF),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _currentIndex,
                  onTap: _onTabTapped,
                  items: [
                    BottomNavigationBarItem(
                      icon: _buildIcon(icono_casa(), 0),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: _buildIcon(icono_lupa(), 1),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: _buildIcon(icono_lista(), 2),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: _buildIcon(icono_persona(), 3),
                      label: '',
                    ),
                  ],
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  selectedItemColor: Color(0xFF95B3FF), // Color del ícono seleccionado
                  unselectedItemColor: Colors.grey, // Color del ícono no seleccionado
                  elevation: 0, // Sin sombra
                  backgroundColor: Colors.transparent, // Fondo transparente
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(Uint8List iconData, int index) {
    return Container(
      width: 40, // Ancho fijo para evitar desbordamientos
      height: 40, // Alto fijo para evitar desbordamientos
      decoration: BoxDecoration(
        color: _currentIndex == index ? Color(0xFF95B3FF) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(5), // Espaciado alrededor del icono
      child: Image.memory(
        iconData, width: 24, height: 24,
        //color: _currentIndex == index ? Colors.white : Colors.black,
      ),
    );
  }
}