import 'package:fleet_service/counter.dart';
import 'package:fleet_service/data.dart';
import 'package:fleet_service/parser.dart';
import 'package:fleet_service/pipelines.dart';
import 'package:fleet_service/report.dart';
import 'package:fleet_service/validator.dart';

/// Поріг вартості для вибірки дорогих робіт.
const costThreshold = 1500.0;

/// Виконавець, для якого рахуються суми.
const contractor = 'СТО Мотор';

/// Кількість записів у коротких звітах.
const shortListCount = 3;

/// Розбирає журнал, перевіряє записи й друкує результати.
void main() {
  final processed = makeCounter();
  final parsed = rawRecords
      .map((line) {
        processed.tick();
        return parseLine(line);
      })
      .nonNulls
      .toList();
  final services = parsed.where((s) => violations(s).isEmpty).toList();
  print('Оброблено рядків: ${processed.value()}');
  print('Розібрано записів: ${parsed.length} з ${rawRecords.length}');
  print('Пройшло перевірку: ${services.length} з ${parsed.length}');
  for (final s in parsed.where((s) => violations(s).isNotEmpty)) {
    print('Відхилено ${s.plate}: ${violations(s).join(', ')}');
  }

  print('\nРоботи дорожчі за $costThreshold:');
  expensiveLabels(services, costThreshold).forEach(print);
  print('Разом: ${expensiveTotal(services, costThreshold).toStringAsFixed(2)}');

  final costs = contractorCosts(services, contractor);
  print('\nВиконавець “$contractor”:');
  print('Сума: ${costs.total.toStringAsFixed(2)}');
  print('Середня вартість: ${costs.average.toStringAsFixed(2)}');

  print('');
  print(buildReport(services));
  print(
    buildReport(
      services,
      title: 'Найдешевші роботи',
      top: shortListCount,
      descending: false,
      withGroups: false,
    ),
  );
  print(
    buildReport(
      services,
      title: 'Найбільший пробіг',
      top: shortListCount,
      by: mileageOf,
      withGroups: false,
    ),
  );

  print('\nНайсвіжіші роботи:');
  recentLines(services).forEach(print);
}
