import 'package:flutter/material.dart';

class PrizoText  extends StatelessWidget {
  /*
  This class is the one managing all the texts of the app in order to standardize them. 
  It accepts a Header type (from 1 to 4) and adjusts the size and weigth of the font according to this number
  it also accepts a fontFamily (Geist if not specified) and a color (Black if not specified)
  */
  final int headerNumber;
  final String text;
  final String fontFamily;
  final Color color;

  const PrizoText({
    super.key,
    required this.headerNumber,
    required this.text,
    this.fontFamily = 'Geist',
    this.color = const Color(0xFF121212),
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double fontSize = width * 0.0322;
    FontWeight fontWeight = FontWeight.w400;

    switch (headerNumber){
      case 1:
        fontSize = width * 0.0966;
        fontWeight = FontWeight.w500;
        break;
      case 2:
        fontSize = width * 0.0644;
        fontWeight = FontWeight.w500;
        
        break;
      case 3: 
        fontSize = width * 0.04293;
        fontWeight = FontWeight.w400;
        break;
      case 4:
        fontSize = width * 0.0322;
        fontWeight = FontWeight.w400;
        break;

    }
    return Text(
              text,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: color
              ),
            );
  }
}

