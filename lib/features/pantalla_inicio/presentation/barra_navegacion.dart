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
    if (mounted){
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initDB();

    final screenWidth = MediaQuery.of(context).size.shortestSide;
    final screenHeight = MediaQuery.of(context).size.longestSide;
    final baseWidth = 375.0;
    final baseHeight = 800.0;
    final scaleFactorWidth = screenWidth / baseWidth;
    final scaleFactorHeight = screenHeight / baseWidth;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _screens[_currentIndex],
          ),
          Positioned(
            bottom: 8 * scaleFactorHeight,
            left: 16 * scaleFactorWidth,
            right: 16 * scaleFactorWidth,
            child: Container(
              height: 27.8 * scaleFactorHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50 * scaleFactorWidth),
                border: Border.all(
                  color: Color(0xFF95B3FF),
                  width: 2.8 * scaleFactorWidth,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(index: 0, iconPath: 'assets/icons/casa_icono.png', iconSize: 26 * scaleFactorWidth),
                  _buildNavItem(index: 1, iconPath: 'assets/icons/lupa_icono.png', iconSize: 22.5 * scaleFactorWidth),
                  _buildNavItem(index: 2, iconPath: 'assets/icons/listas_icono.png', iconSize: 24 * scaleFactorWidth),
                  _buildNavItem(index: 3, iconPath: 'assets/icons/usuario_icono.png', iconSize: 23 * scaleFactorWidth),
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
