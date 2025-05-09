import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class PerfilInterfaz extends StatelessWidget {

  double porcentaje_imagen = 1.07;
  double porcentaje_subir = 0.1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: MediaQuery.of(context).size.width * porcentaje_imagen,
        height: MediaQuery.of(context).size.height * porcentaje_imagen,
        child: Align(
          alignment: Alignment(0, -0.3),
          child: Image.asset(
            'assets/images/perfil_falso.png',
            width: MediaQuery.of(context).size.width * porcentaje_imagen * 0.85,
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PerfilInterfaz(),
  ));
}
