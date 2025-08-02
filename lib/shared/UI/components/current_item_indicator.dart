import 'package:flutter/material.dart';

class CurrentItemIndicator extends StatelessWidget {
  final List<dynamic> items;
  final int currentIndex;
  final double screenWidth;
  final double screenHeight;

  const CurrentItemIndicator({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.screenWidth,
    required this.screenHeight

  });

  @override
  Widget build(BuildContext context) {
    if (items.isNotEmpty) {
      if  (items.length > 1){
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            items.length,
                (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
              width: currentIndex == index ? screenWidth * 0.03 : screenWidth * 0.02,
              height: currentIndex == index ? screenWidth * 0.03 : screenWidth * 0.02,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == index ? Color(0xFF121212) :Color(0xFFD9D9D9),
              ),
            ),
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }
}

