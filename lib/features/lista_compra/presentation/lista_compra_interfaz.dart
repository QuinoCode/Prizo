import 'package:flutter/material.dart';

class ListaCompraInterfaz extends StatelessWidget
{
  String displayText;

  ListaCompraInterfaz({super.key, required this.displayText});

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          body: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(displayText),
                ],
              ),
            ),
            ),
          );
      }
}