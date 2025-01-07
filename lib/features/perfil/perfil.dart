import 'package:flutter/material.dart';
import 'package:prizo/shared/application/icon_service.dart';

class PerfilInterfaz extends StatelessWidget {
  final IconService iconService = new IconService();

  void _navigateToBusqueda() {}
  void _navigateToHome() {}
  void _navigateToPerfilInterfaz() { }
  void _navigateToLista() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Text(
              'Hola!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: MemoryImage(iconService.getPerfil()),
            ),
            SizedBox(height: 20),
            Text(
              'Elena',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'Prizzante 2',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSettingOption(
                    context,
                    icon: Image.memory(
                      iconService.getNotificaciones(),
                      width: 30,
                      height: 30,
                    ),
                    title: 'Notificaciones',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                      activeColor: Colors.white,
                      activeTrackColor: Color(0xFF95B3FF),
                    ),
                  ),
                  _buildSettingOption(
                    context,
                    icon: Image.memory(
                      iconService.getSeguridad(),
                      width: 30,
                      height: 30,
                    ),
                    title: 'Seguridad',
                  ),
                  _buildSettingOption(
                    context,
                    icon: Image.memory(
                      iconService.getAyuda(),
                      width: 30,
                      height: 30,
                    ),
                    title: 'Ayuda',
                  ),
                  _buildSettingOption(
                    context,
                    icon: Image.memory(
                      iconService.getCerrarSesion(),
                      width: 30,
                      height: 30,
                    ),
                    title: 'Cerrar sesión',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.memory(iconService.getCasa(), width: 30, height: 30,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.memory(iconService.getLupa(), width: 30, height: 30,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.memory(iconService.getLista(), width: 30, height: 30,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.memory(iconService.getPersonaAzul(), width: 30, height: 30,),
            label: '',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              _navigateToHome();
              break;
            case 1:
              _navigateToBusqueda();
              break;
            case 2:
              _navigateToLista();
              break;
            case 3:
              _navigateToPerfilInterfaz();
              break;
          }
        },
      ),
    );
  }

  Widget _buildSettingOption(BuildContext context, {required Widget icon, required String title, Widget? trailing, Color? titleColor}) {
    return Column(
      children: [
        ListTile(
          leading: icon, // Usa el widget directamente aquí
          title: Text(
            title,
            style: TextStyle(color: titleColor ?? Colors.black),
          ),
          trailing: trailing,
        ),
        Divider(
          color: Color(0xFF95B3FF),
          thickness: 2.0,
          endIndent: 16.0, // Ajuste para alineación
          indent: 16.0,
        ),
      ],
    );
  }

}

void main() {
  runApp(MaterialApp(
    home: PerfilInterfaz(),
  ));
}