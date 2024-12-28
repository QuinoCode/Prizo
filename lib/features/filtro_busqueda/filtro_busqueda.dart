import 'package:flutter/material.dart';

class FiltroProductosInterfaz extends StatefulWidget {
  List<int> alergenos;
  FiltroProductosInterfaz({super.key, required this.alergenos});

  @override
  _FiltroProductosInterfazState createState() =>
      _FiltroProductosInterfazState();
}

class _FiltroProductosInterfazState extends State<FiltroProductosInterfaz> {
  int? selectedOrder;

  void _toggleAlergeno(int alergenosIndex) {
    setState(() {
      if (widget.alergenos.contains(alergenosIndex)) {
        widget.alergenos.remove(alergenosIndex);
      } else {
        widget.alergenos.add(alergenosIndex);
      }
    });
  }

  void _selectOrder(int orderIndex) {
    setState(() {
      selectedOrder = orderIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasGluten = widget.alergenos.contains(0);
    bool hasLactose = widget.alergenos.contains(1);
    bool hasNuts = widget.alergenos.contains(2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Desactiva la flecha de la izquierda
        backgroundColor: Colors.white,
        title: const Text('Filtrar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Ordenar por:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOrderButton('Precio', 0),
                _buildOrderButton('Novedades', 1),
                _buildOrderButton('Más comprados', 2),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Filtrar por:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Alérgenos',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton('Sin Lactosa', 1, hasLactose),
                _buildFilterButton('Sin gluten', 0, hasGluten),
                _buildFilterButton('Sin frutos secos', 2, hasNuts),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderButton(String text, int index) {
    return ElevatedButton(
      onPressed: () => _selectOrder(index),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedOrder == index ? Colors.blue : Colors.white,
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.blue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildFilterButton(String text, int index, bool isSelected) {
    return ElevatedButton(
      onPressed: () => _toggleAlergeno(index),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.white,
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.blue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}
