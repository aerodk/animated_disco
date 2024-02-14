import 'package:hive/hive.dart';

part 'medicin_tile.g.dart'; // Denne fil vil blive genereret af Hive generator

@HiveType(typeId: 0) // typeId skal være unik for hver HiveType
class MedicinTile extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  DateTime time;

  @HiveField(2)
  final int doseringInterval;

  MedicinTile({required this.name, required this.time, required this.doseringInterval});
}
