import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicin Skema',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MedicinListe(),
    );
  }
}

class MedicinListe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicin Skema'),
      ),
      body: ListView.builder(
        itemCount: 10, // Antal rækker i listen, kan ændres efter behov
        itemBuilder: (context, index) {
          return ListTile(
            title: Row(
              children: <Widget>[
                Expanded(
                  child: Text('Medicin ${index + 1}'), // Medicin navn
                ),
                IconButton(
                  icon: Icon(Icons.arrow_downward),
                  onPressed: () {
                    // Tilføj handling for at tage medicin
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    // Tilføj handling for at slette medicin
                  },
                ),
              ],
            ),
            subtitle: Text('Tid: ${DateTime.now()}'), // Medicin tid, kan ændres
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tilføj handling for at tilføje ny medicin
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
