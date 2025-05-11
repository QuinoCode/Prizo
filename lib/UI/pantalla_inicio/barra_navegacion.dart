import 'package:flutter/material.dart';
import 'package:prizo/main.dart';
import 'package:prizo/shared/database/database_operations.dart';
import 'package:provider/provider.dart';
import '/features/pantalla_inicio/presentation/pantalla_inicio_interfaz.dart';
import '../../product_search/product_search_ui.dart';
import '/features/lista/lista.dart';
import '../../user/perfil.dart';
import 'package:prizo/features/lista_compra/presentation/lista_compra_interfaz.dart';
import 'package:prizo/features/lista_favoritos/presentation/lista_favoritos_interfaz.dart';


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
    ListaFavoritosInterfaz(),
    ListaCompraInterfaz(),
  ];

  void _onTabTapped(int index) {
    Provider.of<PrizoState>(context, listen: false).setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    initDB();
    final navState = Provider.of<PrizoState>(context);

    final screenWidth = MediaQuery.of(context).size.shortestSide;
    final screenHeight = MediaQuery.of(context).size.longestSide;
    final baseWidth = 375.0;
    final scaleFactorWidth = screenWidth / baseWidth;
    final scaleFactorHeight = screenHeight / baseWidth;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _screens[navState.currentIndex],
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
    final navState = Provider.of<PrizoState>(context); // Get the current tab index
    final isSelected = (index == 2 && (navState.currentIndex == 4 || navState.currentIndex == 5)) ? true : navState.currentIndex == index;
    final screenWidth = MediaQuery.of(context).size.width;
    final baseWidth = 375.0;
    final scaleFactor = screenWidth / baseWidth;

    return GestureDetector(
      onTap: () => navState.setIndex(index),
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
