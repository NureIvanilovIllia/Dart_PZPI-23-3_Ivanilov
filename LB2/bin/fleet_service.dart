import 'package:fleet_service/contractor.dart';
import 'package:fleet_service/counter.dart';
import 'package:fleet_service/data.dart';
import 'package:fleet_service/pipelines.dart';
import 'package:fleet_service/report.dart';
import 'package:fleet_service/repository.dart';
import 'package:fleet_service/service.dart';

/// Поріг вартості для вибірки дорогих робіт.
const costThreshold = 1500.0;

/// Виконавець, для якого рахуються суми.
const contractor = Contractor.motor;

/// Номер, за яким шукаємо записи в сховищі.
const searchedPlate = 'AX1234BC';

/// Кількість записів у коротких звітах.
const shortListCount = 3;

/// Розбирає журнал, перевіряє записи й друкує результати.
void main() {
  final processed = makeCounter();
  final parsed = <Service>[];
  for (final line in rawRecords) {
    processed.tick();
    final service = Service.tryParse(line);
    if (service != null) parsed.add(service);
  }
  final services = parsed.where((s) => s.isValid).toList();
  print('Оброблено рядків: ${processed.value()}');
  print('Розібрано записів: ${parsed.length} з ${rawRecords.length}');
  print('Пройшло перевірку: ${services.length} з ${parsed.length}');
  for (final s in parsed.where((s) => !s.isValid)) {
    print('Відхилено ${s.plate}: ${s.violations.join(', ')}');
  }

  print('\nРоботи дорожчі за $costThreshold:');
  expensiveLabels(services, costThreshold).forEach(print);
  print('Разом: ${expensiveTotal(services, costThreshold).toStringAsFixed(2)}');

  final costs = contractorCosts(services, contractor);
  print('\nВиконавець “${contractor.title}”:');
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

  print('\nНаступне обслуговування:');
  sortServices(
    services,
    by: mileageOf,
    descending: true,
  ).take(shortListCount).map(nextServiceLine).forEach(print);

  print('\nДіюча гарантія:');
  warrantyLines(services).forEach(print);

  final repo = Repository<Service>();
  services.forEach(repo.add);
  print('\nСховище:');
  print(
    'Записів для $searchedPlate: '
    '${repo.where((s) => s.plate == searchedPlate).length}',
  );
  print('Перший запис за id: ${repo.findById(services.first.id)}');
}
