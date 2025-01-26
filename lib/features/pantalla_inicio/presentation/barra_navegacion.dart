import 'package:flutter/material.dart';
import 'package:prizo/shared/database/database_operations.dart';
import '/features/pantalla_inicio/presentation/pantalla_inicio_interfaz.dart';
import '/features/productsearch/product_search_ui.dart';
import '/features/lista/lista.dart';
import '/features/perfil/perfil.dart';

class BarraNavegacion extends StatefulWidget {
  @override
  _BarraNavegacionState createState() => _BarraNavegacionState();
}

class _BarraNavegacionState extends State<BarraNavegacion> {
  int _currentIndex = 0;

  void initDB() async{
    await DatabaseOperations.instance.openOrCreateDB();
    DatabaseOperations DO = DatabaseOperations.instance;
  }

  final List<Widget> _screens = [
    PantallaInicio(),
    ProductSearchScreen(),
    ListaInterfaz(),
    PerfilInterfaz(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    initDB();
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
                  width: 3,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    iconPath: 'assets/icons/casa_icono.png',
                    iconSize: 24,
                  ),
                  _buildNavItem(
                    index: 1,
                    iconPath: 'assets/icons/lupa_icono.png',
                    iconSize: 20,
                  ),
                  _buildNavItem(
                    index: 2,
                    iconPath: 'assets/icons/listas_icono.png',
                    iconSize: 22,
                  ),
                  _buildNavItem(
                    index: 3,
                    iconPath: 'assets/icons/usuario_icono.png',
                    iconSize: 22,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String iconPath,
    required double iconSize,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        width: 86,
        height: 52,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Container(
                width: 86,
                height: 52,
                decoration: BoxDecoration(
                  color: Color(0xFF95B3FF).withOpacity(1.0),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ImageIcon(
              AssetImage(iconPath),
              size: iconSize,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
