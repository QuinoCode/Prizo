import 'package:flutter/material.dart';

class PrizoEmailTextField  extends StatelessWidget {
  /*
  This class is the one managing all the texts of the app in order to standardize them. 
  It accepts a Header type (from 1 to 4) and adjusts the size and weigth of the font according to this number
  it also accepts a fontFamily (Geist if not specified) and a color (Black if not specified)
  */

  const PrizoEmailTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return TextField(
              decoration: InputDecoration(
                hintText: 'Correo electrónico', // placeholder
                hintStyle: TextStyle(
                  fontSize: width * 0.04293,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF504F4F),
                ) ,

                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF95B3FF))
                ), 
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF95B3FF))
                ), 
              ),
            ) ;
  } 
}

class PrizoPassTextField  extends StatefulWidget {
  /*
  This class is the one managing all the texts of the app in order to standardize them. 
  It accepts a Header type (from 1 to 4) and adjusts the size and weigth of the font according to this number
  it also accepts a fontFamily (Geist if not specified) and a color (Black if not specified)
  */
  const PrizoPassTextField({
    super.key,
  });

  @override
  State<PrizoPassTextField> createState() => _PrizoPassTextFieldState();
}

class _PrizoPassTextFieldState extends State<PrizoPassTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return TextField(
              obscureText: _obscureText, // hides password
              decoration: InputDecoration(
                hintText: 'Contraseña',
                hintStyle: TextStyle(
                  fontSize: width * 0.04293,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF504F4F),
                ) ,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF95B3FF))
                ), 
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF95B3FF))
                ), 

                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                     _obscureText  = !_obscureText;
                    });
                  },
                  icon: SizedBox(
                    width: width * 0.045,
                    child: Image.asset('assets/icons/password_toggle_eye.png')
                  ),
                ),
              ),
            ) ;
  } 
}
