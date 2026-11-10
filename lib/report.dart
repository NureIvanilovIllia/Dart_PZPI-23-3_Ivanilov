import 'plate.dart';
import 'service.dart';
import 'validator.dart';

/// Скільки записів показує звіт за замовчуванням.
const defaultTopCount = 5;

/// Скільки найсвіжіших робіт показує [recentLines] за замовчуванням.
const defaultRecentCount = 3;

/// Групує записи за типом робіт.
Map<String, List<Service>> groupByWork(List<Service> services) {
  final groups = <String, List<Service>>{};
  for (final s in services) {
    groups.putIfAbsent(s.workType, () => []).add(s);
  }
  return groups;
}

/// Сума вартості по кожній групі.
Map<String, double> totalsByWork(Map<String, List<Service>> groups) => {
  for (final group in groups.entries)
    group.key: group.value.fold(0.0, (sum, s) => sum + s.cost),
};

/// Критерій сортування: вартість роботи.
num costOf(Service s) => s.cost;

/// Критерій сортування: пробіг автомобіля.
num mileageOf(Service s) => s.mileage;

/// Сортує за критерієм [by] (вартість або пробіг).
///
/// Напрямок задає [descending]; вхідний список не змінюється.
List<Service> sortServices(
  List<Service> services, {
  num Function(Service) by = costOf,
  bool descending = false,
}) {
  final sign = descending ? -1 : 1;
  return [...services]..sort((a, b) => sign * by(a).compareTo(by(b)));
}

/// Збирає текстовий звіт.
///
/// [top] – скільки записів показати після сортування за критерієм [by],
/// [descending] – напрямок сортування, [withGroups] – чи друкувати суми за
/// типами робіт.
String buildReport(
  List<Service> services, {
  String title = 'Звіт про обслуговування',
  int top = defaultTopCount,
  num Function(Service) by = costOf,
  bool descending = true,
  bool withGroups = true,
}) {
  final buffer = StringBuffer()..writeln(title);

  if (withGroups) {
    buffer.writeln('Витрати за типами робіт:');
    final groups = groupByWork(services);
    totalsByWork(groups).forEach((type, total) {
      buffer.writeln(
        '  $type – ${groups[type]!.length} шт., ${total.toStringAsFixed(2)}',
      );
    });
  }

  final direction = descending ? 'спадання' : 'зростання';
  buffer.writeln('Записи ($direction):');
  final sorted = sortServices(
    services,
    by: by,
    descending: descending,
  ).take(top);
  var number = 1;
  for (final s in sorted) {
    buffer.writeln(
      '  ${number++}. ${s.plate}, ${s.workType}, ${s.mileage} км, '
      '${s.cost.toStringAsFixed(2)}',
    );
  }
  return buffer.toString();
}

DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// Вік запису в днях відносно [referenceDate].
int ageInDays(Service s) => _day(referenceDate).difference(_day(s.date)).inDays;

/// Рядки про [count] найсвіжіших робіт, номери приховано.
List<String> recentLines(
  List<Service> services, {
  int count = defaultRecentCount,
}) {
  final byDate = [...services]..sort((a, b) => b.date.compareTo(a.date));
  return [
    for (final s in byDate.take(count))
      '${maskPlate(s.plate)}, ${s.workType}, ${ageInDays(s)} дн. тому',
  ];
}
