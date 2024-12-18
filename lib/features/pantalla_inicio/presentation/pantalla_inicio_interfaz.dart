import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PantallaInicio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String currentDay = DateFormat.EEEE('es_ES').format(DateTime.now());

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      'PRIZO',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '¿Qué quieres comprar hoy?',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar productos...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.qr_code_scanner, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Ofertas de la semana',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(10, (i) => i == index ?
                            Icon(Icons.circle, size: 8, color: Colors.blue) :
                            Icon(Icons.circle, size: 6, color: Colors.grey)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Divider(color: Colors.blue),
              SizedBox(height: 20),
              Center(
                child: Text(
                  '¡Hoy es $currentDay de compra!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                    .map((day) => CircleAvatar(
                  backgroundColor: day == currentDay[0].toUpperCase()
                      ? Colors.blue
                      : Colors.grey[300],
                  child: Text(
                    day,
                    style: TextStyle(
                      color: day == currentDay[0].toUpperCase()
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ))
                    .toList(),
              ),
              SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.shopping_bag, size: 150, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      '¡Recuerda llevarte tu bolsa\nde tela!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Tus supermercados cercanos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Column(
                children: List.generate(3, (index) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.store, color: Colors.white),
                  ),
                  title: Text('Supermercado ${index + 1}'),
                  subtitle: Text('Distancia: ${index * 0.5 + 0.3} km\nDirección: Calle Falsa ${index + 123}'),
                )),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {},
      ),
    );
  }
}