import 'package:hive/hive.dart';

part 'conversion_history.g.dart';

@HiveType(typeId: 0)
class ConversionHistory extends HiveObject {
  @HiveField(0)
  final String inputUnit;

  @HiveField(1)
  final double inputValue;

  @HiveField(2)
  final String outputUnit;

  @HiveField(3)
  final double outputValue;

  @HiveField(4)
  final DateTime dateTime;

  ConversionHistory({
    required this.inputUnit,
    required this.inputValue,
    required this.outputUnit,
    required this.outputValue,
    required this.dateTime,
  });
}
