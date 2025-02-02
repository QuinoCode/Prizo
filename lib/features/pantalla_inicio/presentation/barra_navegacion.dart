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

  void initDB() async {
    await DatabaseOperations.instance.openOrCreateDB();
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

    final screenWidth = MediaQuery.of(context).size.width;

    final baseWidth = 375.0;
    final scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _screens[_currentIndex],
          ),
          Positioned(
            bottom: 16 * scaleFactor,
            left: 16 * scaleFactor,
            right: 16 * scaleFactor,
            child: Container(
              height: 60 * scaleFactor,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50 * scaleFactor),
                border: Border.all(
                  color: Color(0xFF95B3FF),
                  width: 2.8 * scaleFactor,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(index: 0, iconPath: 'assets/icons/casa_icono.png', iconSize: 26 * scaleFactor),
                  _buildNavItem(index: 1, iconPath: 'assets/icons/lupa_icono.png', iconSize: 22.5 * scaleFactor),
                  _buildNavItem(index: 2, iconPath: 'assets/icons/listas_icono.png', iconSize: 24 * scaleFactor),
                  _buildNavItem(index: 3, iconPath: 'assets/icons/usuario_icono.png', iconSize: 23 * scaleFactor),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final baseWidth = 375.0;
    final scaleFactor = screenWidth / baseWidth;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: 80 * scaleFactor,
        height: 50 * scaleFactor,
        alignment: Alignment.center,
        constraints: BoxConstraints(
          minWidth: 48 * scaleFactor,
          minHeight: 48 * scaleFactor,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Container(
                width: 80 * scaleFactor,
                height: 50 * scaleFactor,
                decoration: BoxDecoration(
                  color: Color(0xFF95B3FF),
                  borderRadius: BorderRadius.circular(30 * scaleFactor),
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