import 'package:flutter/material.dart';
import '/features/pantalla_inicio/presentation/pantalla_inicio_interfaz.dart';
import '/features/productsearch/productsearch.ui.dart';

class BarraNavegacion extends StatefulWidget {
  @override
  _BarraNavegacionState createState() => _BarraNavegacionState();
}

class _BarraNavegacionState extends State<BarraNavegacion> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    PantallaInicio(),
    ProductSearchScreen(),
    // Center(child: Text('Favoritos')),
    // Center(child: Text('Perfil')),
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
                borderRadius: BorderRadius.circular(50), // Forma ovalada
                border: Border.all(
                  color: Colors.blueAccent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _currentIndex,
                  onTap: _onTabTapped,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: '', // Sin texto debajo del icono
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: '',
                    ),
                  ],
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  selectedItemColor: Colors.blueAccent, // Color del ícono seleccionado
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
}
