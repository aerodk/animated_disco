import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicin Skema',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MedicinGrid(),
    );
  }
}

class MedicinTile {
  String name;
  DateTime time;
  int doseringInterval; // Timer mellem doseringer

  MedicinTile(
      {required this.name, required this.time, this.doseringInterval = 4});
}

class MedicinGrid extends StatefulWidget {
  const MedicinGrid({super.key});

  @override
  _MedicinGridState createState() => _MedicinGridState();
}

class _MedicinGridState extends State<MedicinGrid> {
  List<MedicinTile> medicinList = List.generate(
    12,
    (index) => MedicinTile(
        name: 'Medicin $index',
        time: DateTime.now().add(Duration(hours: index - 6))),
  );

  void _showTimePicker(MedicinTile tile) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        tile.time = DateTime(
          tile.time.year,
          tile.time.month,
          tile.time.day,
          picked.hour,
          picked.minute,
        ).add(const Duration(hours: 4));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicin Skema'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMedicin,
        child: Icon(Icons.add),
      ),
      body: GridView.custom(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 120, // Maksimal bredde for hver tile
          childAspectRatio: 1, // Forholdet mellem bredde og højde for hver tile
          crossAxisSpacing: 10, // Afstand mellem tiles horisontalt
          mainAxisSpacing: 10, // Afstand mellem tiles vertikalt
        ),
        childrenDelegate: SliverChildBuilderDelegate(
          (context, index) {
            MedicinTile tile = medicinList[index];
            bool isPast = tile.time.isBefore(DateTime.now());
            return GestureDetector(
              onTap: () => _showTimePicker(tile),
              child: Card(
                color: isPast ? Colors.green : Colors.red,
                child: GridTile(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.medication, size: 24),
                      SizedBox(height: 8),
                      Text(
                        tile.name, // Brug navnet fra MedicinTile objektet
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 8),
                      Text(
                        DateFormat('HH:mm').format(tile.time),
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: medicinList.length,
        ),
      ),
    );
  }

  void _addNewMedicin() async {
    String medicinNavn = '';
    int doseringInterval = 4;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      // Brugeren skal trykke på knapper for at lukke dialogen
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tilføj ny medicin'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Medicin navn',
                    ),
                    onChanged: (value) {
                      medicinNavn = value;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (doseringInterval > 1) {
                              doseringInterval--;
                            }
                          });
                        },
                      ),
                      Text('$doseringInterval timer'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            doseringInterval++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuller'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                DateTime nextDoseTime =
                    DateTime.now().add(Duration(hours: doseringInterval));
                setState(() {
                  medicinList.add(
                    MedicinTile(
                        name: medicinNavn,
                        time: nextDoseTime,
                        doseringInterval: doseringInterval),
                  );
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
