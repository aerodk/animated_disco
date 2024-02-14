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
  DateTime time;
  MedicinTile({required this.time});
}

class MedicinGrid extends StatefulWidget {
  const MedicinGrid({super.key});

  @override
  _MedicinGridState createState() => _MedicinGridState();
}

class _MedicinGridState extends State<MedicinGrid> {
  List<MedicinTile> medicinList = List.generate(
    12,
        (index) => MedicinTile(time: DateTime.now().add(Duration(hours: index - 6))),
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
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          childAspectRatio: 1,
        ),
        itemCount: medicinList.length,
        itemBuilder: (context, index) {
          MedicinTile tile = medicinList[index];
          bool isPast = tile.time.isBefore(DateTime.now());
          return GestureDetector(
            onTap: () => _showTimePicker(tile),
            child: Card(
              color: isPast ? Colors.green : Colors.red,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.medication, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    'Medicin ${index + 1}',
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
          );
        },
      ),
    );
  }
}
