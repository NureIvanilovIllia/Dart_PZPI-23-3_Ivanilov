import 'package:fleet_service/data.dart';
import 'package:fleet_service/parser.dart';
import 'package:fleet_service/pipelines.dart';
import 'package:fleet_service/validator.dart';

const costThreshold = 1500.0;
const contractor = 'СТО Мотор';

void main() {
  final parsed = rawRecords.map(parseLine).nonNulls.toList();
  final services = parsed.where(isValid).toList();
  print('Розібрано записів: ${parsed.length} з ${rawRecords.length}');
  print('Пройшло перевірку: ${services.length} з ${parsed.length}');

  print('\nРоботи дорожчі за $costThreshold:');
  expensiveLabels(services, costThreshold).forEach(print);
  print('Разом: ${expensiveTotal(services, costThreshold).toStringAsFixed(2)}');

  final costs = contractorCosts(services, contractor);
  print('\nВиконавець “$contractor”:');
  print('Сума: ${costs.total.toStringAsFixed(2)}');
  print('Середня вартість: ${costs.average.toStringAsFixed(2)}');
}
