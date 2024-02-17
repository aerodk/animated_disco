// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicin_tile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicinTileAdapter extends TypeAdapter<MedicinTile> {
  @override
  final int typeId = 0;

  @override
  MedicinTile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicinTile(
      name: fields[0] as String,
      time: fields[1] as DateTime,
      doseringInterval: fields[2] as int,
      doseAmount: fields[3] == null ? 0 : fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MedicinTile obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.doseringInterval)
      ..writeByte(3)
      ..write(obj.doseAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicinTileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
