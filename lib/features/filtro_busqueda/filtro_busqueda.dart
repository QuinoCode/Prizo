import 'package:flutter/material.dart';

class FiltroProductosInterfaz extends StatefulWidget {
  List<int> alergenos;
  FiltroProductosInterfaz({super.key, required this.alergenos});

  @override
  _FiltroProductosInterfazState createState() => _FiltroProductosInterfazState();
}

class _FiltroProductosInterfazState extends State<FiltroProductosInterfaz> {

  void _toggleAlergeno(int alergenosIndex) {
    setState(() {
      if (widget.alergenos.contains(alergenosIndex)) {
        widget.alergenos.remove(alergenosIndex);
      } else {
        widget.alergenos.add(alergenosIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    bool hasGluten = widget.alergenos.contains(0);
    bool hasLactose = widget.alergenos.contains(1);
    bool hasNuts = widget.alergenos.contains(2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros de Productos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _toggleAlergeno(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasGluten ? Colors.blue : Colors.grey,
              ),
              child: const Text(
                'Sin gluten',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _toggleAlergeno(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasLactose ? Colors.blue : Colors.grey,
              ),
              child: const Text(
                'Sin lactosa',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _toggleAlergeno(2);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasNuts ? Colors.blue : Colors.grey,
              ),
              child: const Text(
                'Sin frutos secos',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}