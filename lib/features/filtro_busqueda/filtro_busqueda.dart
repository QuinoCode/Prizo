import 'package:flutter/material.dart';

class FiltroProductosInterfaz extends StatefulWidget {
  List<int> alergenos;
  FiltroProductosInterfaz({super.key, required this.alergenos});

  @override
  _FiltroProductosInterfazState createState() =>
      _FiltroProductosInterfazState();
}

class _FiltroProductosInterfazState extends State<FiltroProductosInterfaz> {
  List<int> selectedOrders = [];  // Usar una lista para permitir múltiples selecciones

  void _toggleAlergeno(int alergenosIndex) {
    setState(() {
      if (widget.alergenos.contains(alergenosIndex)) {
        widget.alergenos.remove(alergenosIndex);
      } else {
        widget.alergenos.add(alergenosIndex);
      }
    });
  }

  void _toggleOrder(int orderIndex) {
    setState(() {
      if (selectedOrders.contains(orderIndex)) {
        selectedOrders.remove(orderIndex); // Desmarcar si ya está seleccionado
      } else {
        selectedOrders.add(orderIndex); // Agregar si no está seleccionado
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasGluten = widget.alergenos.contains(0);
    bool hasLactose = widget.alergenos.contains(1);
    bool hasNuts = widget.alergenos.contains(2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Text('Filtrar', style: TextStyle(fontFamily: 'Geist', fontSize: MediaQuery.of(context).size.width * 0.0615, fontWeight: FontWeight.w500)),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              padding: EdgeInsets.fromLTRB(0, 20, 13, 0),
              color: Color.fromARGB(255,18,18,18),
              icon: ImageIcon(AssetImage('assets/icons/x.png'),size: MediaQuery.of(context).size.width * 0.07,),
              onPressed: () {
                Navigator.pop(context, widget.alergenos);
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
                color: Color(0xFF95B3FF),
                height: 2.0,
            )
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height:30),
            Text(
              'Ordenar por:',
              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.0923, fontFamily: 'Geist', fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spaces between items
                children: [
                  _buildOrderButton('Precio', 0),
                  SizedBox(width: 12),
                  _buildOrderButton('Novedades', 1),
                  SizedBox(width: 12),
                  _buildOrderButton('Más comprados', 2),
                ],
              ),
            ),
            const SizedBox(height: 54),
            Text(
              'Filtrar por:',
              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.0923, fontFamily: 'Geist', fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Alérgenos',
              style: TextStyle(fontSize: MediaQuery.of(context).size.shortestSide * 0.0644, fontFamily: 'Geist', fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spaces between items
                children: [
                  _buildFilterButton('Sin Lactosa', 1, hasLactose),
                  SizedBox(width: 12),
                  _buildFilterButton('Sin gluten', 0, hasGluten),
                  SizedBox(width: 12),
                  _buildFilterButton('Sin frutos secos', 2, hasNuts),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderButton(String text, int index) {
    return ElevatedButton(
      onPressed: () => _toggleOrder(index),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedOrders.contains(index)
            ? Color(0xFF95B3FF)
            : Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Colors.transparent,
        side: BorderSide(width: 2, color: Color(0xFF95B3FF)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      child: Text(text, style: TextStyle(fontSize: 14, fontFamily: 'Geist', fontWeight: FontWeight.w400)),
    );
  }

  Widget _buildFilterButton(String text, int index, bool isSelected) {
    return ElevatedButton(
      onPressed: () => _toggleAlergeno(index),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF95B3FF) : Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Colors.transparent,
        side: BorderSide(width: 2, color: Color(0xFF95B3FF)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      child: Text(text, style: TextStyle(fontSize: 14, fontFamily: 'Geist', fontWeight: FontWeight.w400)),
    );
  }
}
