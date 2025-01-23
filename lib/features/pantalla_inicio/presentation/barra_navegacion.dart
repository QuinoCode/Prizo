import 'package:flutter/material.dart';
import '/features/pantalla_inicio/presentation/pantalla_inicio_interfaz.dart';
import '/features/productsearch/productsearch.ui.dart';
import '/features/perfil/perfil.dart';

class BarraNavegacion extends StatefulWidget {
  @override
  _BarraNavegacionState createState() => _BarraNavegacionState();
}

class _BarraNavegacionState extends State<BarraNavegacion> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    PantallaInicio(),
    ProductSearchScreen(),
    PerfilInterfaz(),// Center(child: Text('Favoritos')),
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
                borderRadius: BorderRadius.circular(50), // Forma ovalada
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
                  items: const [
                    BottomNavigationBarItem(
                      icon: const ImageIcon(
                        AssetImage('assets/icons/casa_icono.png'),
                        size: 24,
                      ),
                      label: '', // Sin texto debajo del icono
                    ),
                    BottomNavigationBarItem(
                      icon: const ImageIcon(
                        AssetImage('assets/icons/lupa_icono.png'),
                        size: 20,
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: const ImageIcon(
                        AssetImage('assets/icons/listas_icono.png'),
                        size: 22,
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: const ImageIcon(
                        AssetImage('assets/icons/usuario_icono.png'),
                        size: 22,
                      ),
                      label: '',
                    ),
                  ],
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  selectedItemColor: Color(0xFF95B3FF), // Color del ícono seleccionado
                  unselectedItemColor: Colors.black, // Color del ícono no seleccionado
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
