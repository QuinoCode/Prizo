import 'package:flutter/material.dart';
import 'package:prizo/shared/UI/components/prizo_text.dart';
import 'package:prizo/shared/UI/components/prizo_text_field.dart';
import 'package:prizo/shared/database/database_operations.dart';
import 'package:sqflite/sqflite.dart';



class LoginInterface extends StatelessWidget {

  const LoginInterface({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.05),
                PrizoText(headerNumber: 1, text: "¡Hola!"),
                PrizoText(headerNumber: 2, text: "Inicia sesión"),
                SizedBox(height: height * 0.05),
                PrizoEmailTextField(),
                SizedBox(height: height * 0.02),
                PrizoPassTextField()
              ],
            ),
            SizedBox(height: height * 0.05),
            PrizoText(headerNumber: 4, text: "o con estas opciones", color: Color(0xFF504F4F)),
            SizedBox(height: height * 0.05),
            SignInButtonMock(imagePath: 'assets/icons/google_icon.png', buttonText: 'Iniciar sesión con google'),
            SizedBox(height: height * 0.035),
            SignInButtonMock(imagePath: 'assets/icons/facebook_icon.png', buttonText: 'Iniciar sesión con facebook'),
            SizedBox(height: height * 0.035),
            SignInButtonMock(imagePath: 'assets/icons/apple_icon.png', buttonText: 'Iniciar sesión con apple'),
            SizedBox(height: height * 0.05),
            PrizoText(headerNumber: 3, text: "Continuar sin iniciar sesión")
          ],
        ),
      ),
    );
  }
}


class SignInButtonMock extends StatelessWidget {
  final String imagePath;
  final String buttonText;
  const SignInButtonMock({
    super.key,
    required this.imagePath,
    required this.buttonText
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height * 0.065,
      child: OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF95B3FF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.5),
          ),
          padding: EdgeInsets.symmetric(horizontal: width * 0.03),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: width * 0.035),
            SizedBox(
              width: width * 0.048,
              child: Image.asset(
                imagePath,
              ),
            ),
            //SizedBox(width: 30),
            SizedBox(width: width * 0.073),
            // Centered text
            Text(
              buttonText,
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: width * 0.04293,
                fontWeight: FontWeight.w500,
                color: Color(0xFF121212),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

    
