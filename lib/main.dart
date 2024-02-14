import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'medicin_tile.dart';

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

class MedicinGrid extends StatefulWidget {
  const MedicinGrid({super.key});

  @override
  _MedicinGridState createState() => _MedicinGridState();
}

class _MedicinGridState extends State<MedicinGrid> {
  List<MedicinTile> medicinList = [];
  late Future<Box<MedicinTile>> _hiveBox;
  bool _isLoadingHive = true;

  @override
  void initState() {
    super.initState();
    // Initialiser Hive
    _loadMedicinTiles();
  }

  void _loadMedicinTiles() async {
    _isLoadingHive = true;
    if (!kIsWeb) {
      // Kun kald Hive.init med en sti, når det ikke er på web
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
    }
    Hive.registerAdapter(MedicinTileAdapter());
    // Åbn en Hive-boks asynkront
    _hiveBox = Hive.openBox<MedicinTile>('medicinBox');
    _hiveBox.then((box) {
      if (box.isEmpty) {
        // Boksen er tom, indsæt standard medicin tiles
        final DateTime now = DateTime.now();
        box.add(MedicinTile(name: 'Panodil', time: now, doseringInterval: 4));
        box.add(MedicinTile(name: 'Treo', time: now, doseringInterval: 6));
        box.add(MedicinTile(name: 'Medicin 3', time: now, doseringInterval: 8));
      }

      setState(() {
        medicinList = box.values.toList();
        _isLoadingHive = false;
      });
    });
  }

  void _showTimePicker(MedicinTile tile) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
               return MediaQuery(
                 data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                 child: child!,
               );
             },
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

      // Save new info
      tile.save();
    }
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicin Skema'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMedicin,
        child: const Icon(Icons.add),
      ),
      body: _isLoadingHive
          ? const Center(child: CircularProgressIndicator())
          : GridView.custom(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 120,
          childAspectRatio: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        childrenDelegate: SliverChildBuilderDelegate(
              (context, index) {
            MedicinTile tile = medicinList[index];
            bool isPast = tile.time.isBefore(DateTime.now());
            return GestureDetector(
              onTap: () => _showTimePicker(tile),
              onLongPress: () => _confirmDeletion(context, index),
              child: Card(
                color: isPast ? Colors.green : Colors.red,
                child: GridTile(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.medication, size: 24),
                      const SizedBox(height: 8),
                      Text(
                        tile.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('HH:mm').format(tile.time),
                        style: const TextStyle(fontSize: 16),
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

  void _confirmDeletion(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Bekræft sletning"),
          content: Text("Er du sikker på, at du vil slette '${medicinList.elementAt(index).name}'?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Annuller"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Slet"),
              onPressed: () {
                _deleteMedicin(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteMedicin(int index) async {
    _hiveBox.then((value) => value.deleteAt(index)); // Slet fra Hive-boksen baseret på index
    setState(() {
      medicinList.removeAt(index); // Opdaterer listen, der vises i UI
    });
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
          title: const Text('Tilføj ny medicin'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    autofocus: true,
                    decoration: const InputDecoration(
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
                        icon: const Icon(Icons.remove),
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
                        icon: const Icon(Icons.add),
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
              child: const Text('Annuller'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                DateTime nextDoseTime =
                    DateTime.now().add(Duration(hours: doseringInterval));
                var medicinTile = MedicinTile(
                    name: medicinNavn,
                    time: nextDoseTime,
                    doseringInterval: doseringInterval);
                _hiveBox.then((value) => value.add(medicinTile));
                setState(() {
                  medicinList.add(
                    medicinTile,
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
