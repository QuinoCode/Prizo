import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PantallaInicio extends StatefulWidget {
  @override
  _PantallaInicioState createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

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
              SizedBox(height: 40),
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  Container(
                    height: 200, // Incrementar altura para productos más grandes
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 10, // Número de productos
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(10, (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: currentIndex == index ? 12 : 8,
                      height: currentIndex == index ? 12 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentIndex == index ? Colors.blue : Colors.grey,
                      ),
                    )),
                  ),
                ],
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
              Container(
                height: 120, // Altura para lista horizontal
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // Número de supermercados
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.store, color: Colors.white),
                        ),
                        title: Text('Supermercado ${index + 1}'),
                        subtitle: Text('Distancia: ${index * 0.5 + 0.3} km\nDirección: Calle Falsa ${index + 123}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(16), // Separación del borde de la pantalla
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.blue, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.blue),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.search, color: Colors.grey),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.list, color: Colors.grey),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}