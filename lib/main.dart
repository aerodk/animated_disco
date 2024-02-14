import 'package:flutter/material.dart';

/*void main() {
  runApp(const MyApp());
}
*/
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicin Skema',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MedicinListe(),
    );
  }
}

class MedicinListe extends StatelessWidget {
  const MedicinListe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicin Skema'),
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
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: () {
                    // Tilføj handling for at tage medicin
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
