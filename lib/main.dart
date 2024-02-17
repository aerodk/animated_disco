import 'package:animated_disco/quick_actions_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quick_actions/quick_actions.dart';

import 'medicin_tile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicin tracker',
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
  MedicinGridState createState() => MedicinGridState();
}

class MedicinGridState extends State<MedicinGrid> {
  List<MedicinTile> medicinList = [];
  late Future<Box<MedicinTile>> _hiveBox;
  bool _isLoadingHive = true;

  bool _hiveInit = false;

  @override
  void initState() {
    super.initState();
    // Initialiser Hive
    _loadMedicinTiles();
    _setupQuickActions();
  }

  void _setupQuickActions() async {
    await _initHive();
    const QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      // Her kan du håndtere dine quick actions
      if (shortcutType.startsWith("dose")) {
        _handleQuickAction(shortcutType);
      } else {
        if (kDebugMode) {
          print("Unknown shortcut type received $shortcutType");
        }
      }
    });
    QuickActionsManager().updateQuickActions();
  }

  void _handleQuickAction(String dosis) async {
    String doseOf = dosis.substring(5);

    var box = await _hiveBox; //Hive.openBox<MedicinTile?>('medicinBox');
    MedicinTile? medOf = box.values
        .firstWhere((element) => element.name == doseOf);
    medOf.registerDose();
    medOf.save();
  }

  void _loadMedicinTiles() async {
    _isLoadingHive = true;
    await _initHive();
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

  Future<void> _initHive() async {
    if (!kIsWeb) {
      // Kun kald Hive.init med en sti, når det ikke er på web
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
    }
    if (!_hiveInit) {
      Hive.registerAdapter(MedicinTileAdapter());
      _hiveInit = true;
    }
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
      var day = DateTime.now();
      setState(() {
        tile.time = DateTime(
          day.year,
          day.month,
          day.day,
          picked.hour,
          picked.minute,
        ).add(Duration(hours: tile.doseringInterval));
      });

      // Update dosage and save new info in Hive
      tile.registerDose();
      tile.save();
    }
  }

  @override
  void dispose() {
    _hiveInit = false;
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicin tracker'),
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
                    onLongPress: () =>
                        _showEditMedicinDialog(context, tile, index),
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

  void _showEditMedicinDialog(
      BuildContext context, MedicinTile tile, int index) async {
    // Opret TextEditingController for hvert felt du ønsker at redigere
    final TextEditingController doseringIntervalController =
        TextEditingController(text: tile.doseringInterval.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Rediger ${tile.name}"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(height: 20),
                // Tilføj lidt afstand mellem felterne
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text("Dosering Interval (timer)", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: doseringIntervalController,
                      decoration: const InputDecoration(
                        hintText: "Indtast dosering interval i timer",
                        // Tilføj label til inputfeltet også, hvis ønsket
                        labelText: "Dosering Interval",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Annuller"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Slet"),
              onPressed: () {
                _deleteMedicin(context, index);
                // _confirmDeletion(context, index); // Implementer _deleteMedicin som før
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Gem"),
              onPressed: () {
                // Opdater tile med de nye værdier
                setState(() {
                  tile.doseringInterval =
                      int.tryParse(doseringIntervalController.text) ??
                          tile.doseringInterval;
                  tile.save(); // Gem ændringerne i Hive
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteMedicin(BuildContext context, int index) {
    // Gem en kopi af den slettede MedicinTile, før du sletter den
    MedicinTile deletedTile = medicinList[index];
    int? deletedTileKey = deletedTile
        .key; // Antager at MedicinTile er et HiveObject og har en unik nøgle

    // Fjern tile fra listen og Hive-boksen
    setState(() {
      medicinList.removeAt(index);
      Hive.box<MedicinTile>('medicinBox').delete(deletedTileKey);
    });

    // Vis en SnackBar med en fortryd-knap
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Medicin ' '${deletedTile.name} slettet'),
        action: SnackBarAction(
          label: 'Fortryd',
          onPressed: () {
            // Gendan den slettede MedicinTile, hvis brugeren fortryder
            setState(() {
              Hive.box<MedicinTile>('medicinBox')
                  .put(deletedTileKey, deletedTile);
              medicinList.insert(index,
                  deletedTile); // Indsæt den gendannede tile på dens oprindelige plads
            });
          },
        ),
        duration: const Duration(
            seconds: 5), // Giver brugeren 5 sekunder til at reagere
      ),
    );
  }

  void _addNewMedicin() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String medicinNavn = '';
        int doseringInterval = 4;
        String? fejlMeddelelse;

        List<Widget> buildActions(StateSetter setState) {
          return <Widget>[
            TextButton(
              child: const Text('Annuller'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: fejlMeddelelse != null ? null : () async {
                DateTime nextDoseTime = DateTime.now().subtract(Duration(hours: doseringInterval));
                var medicinTile = MedicinTile(
                  name: medicinNavn,
                  time: nextDoseTime,
                  doseringInterval: doseringInterval,
                );
                await _hiveBox.then((value) => value.add(medicinTile));
                setState(() {
                  medicinList.add(medicinTile);
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ];
        }

        return AlertDialog(
          title: const Text('Tilføj ny medicin'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Medicin navn',
                      errorText: fejlMeddelelse,
                    ),
                    onChanged: (value) {
                      medicinNavn = value;
                      bool used = medicinList.any((element) => element.name.toLowerCase() == value.toLowerCase());
                      setState(() {
                        fejlMeddelelse = used ? 'Medicinnavnet eksisterer allerede' : null;
                      });
                    },
                  ),
                  // Din Row widget for doseringInterval
                ],
              );
            },
          ),
          actions: buildActions((state) {}),
        );
      },
    );
  }
}
