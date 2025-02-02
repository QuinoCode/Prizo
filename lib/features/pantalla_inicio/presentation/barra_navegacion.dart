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
    // DatabaseOperations DO = DatabaseOperations.instance;
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

    final navBarHeight = screenWidth < 360 ? 50.0 : 63.0;
    final iconSizeFactor = screenWidth / 375;

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
              height: navBarHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Color(0xFF95B3FF),
                  width: 3,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(index: 0, iconPath: 'assets/icons/casa_icono.png', iconSize: 26 * iconSizeFactor),
                  _buildNavItem(index: 1, iconPath: 'assets/icons/lupa_icono.png', iconSize: 22.5 * iconSizeFactor),
                  _buildNavItem(index: 2, iconPath: 'assets/icons/listas_icono.png', iconSize: 24 * iconSizeFactor),
                  _buildNavItem(index: 3, iconPath: 'assets/icons/usuario_icono.png', iconSize: 23 * iconSizeFactor),
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
    final itemWidth = screenWidth < 360 ? 70.0 : 86.0;
    final itemHeight = screenWidth < 360 ? 45.0 : 52.0;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.translucent, // Permite detectar toques en áreas vacías
      child: Container(
        width: itemWidth,
        height: itemHeight,
        alignment: Alignment.center,
        constraints: BoxConstraints(
          minWidth: 48, // Área mínima de toque
          minHeight: 48,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Container(
                width: itemWidth,
                height: itemHeight,
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