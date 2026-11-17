import 'plate.dart';
import 'service.dart';
import 'work.dart';

/// Скільки записів показує звіт за замовчуванням.
const defaultTopCount = 5;

/// Скільки найсвіжіших робіт показує [recentLines] за замовчуванням.
const defaultRecentCount = 3;

/// Групує записи за типом робіт.
Map<String, List<Service>> groupByWork(List<Service> services) {
  final groups = <String, List<Service>>{};
  for (final s in services) {
    groups.putIfAbsent(s.work.name, () => []).add(s);
  }
  return groups;
}

/// Кількість записів і сума вартості по кожній групі.
Map<String, ({int count, double total})> statsByWork(
  Map<String, List<Service>> groups,
) => {
  for (final group in groups.entries)
    group.key: (
      count: group.value.length,
      total: group.value.fold(0.0, (sum, s) => sum + s.cost),
    ),
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
    statsByWork(groupByWork(services)).forEach((type, stats) {
      buffer.writeln(
        '  $type – ${stats.count} шт., ${stats.total.toStringAsFixed(2)}',
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
  for (final (index, s) in sorted.indexed) {
    buffer.writeln(
      '  ${index + 1}. ${s.plate}, ${s.work.name}, ${s.mileage} км, '
      '${s.cost.toStringAsFixed(2)}',
    );
  }
  return buffer.toString();
}

/// Рядок про наступне обслуговування цього виду робіт після запису [s].
String nextServiceLine(Service s) =>
    '${s.plate}, ${s.work.name} – на ${s.work.nextServiceAt(s.mileage)} км '
    '(${categoryOf(s.work)})';

/// Рядки про [count] найсвіжіших робіт, номери приховано.
List<String> recentLines(
  List<Service> services, {
  int count = defaultRecentCount,
}) {
  final byDate = [...services]..sort((a, b) => b.date.compareTo(a.date));
  return [
    for (final s in byDate.take(count))
      '${maskPlate(s.plate)}, ${s.work.name}, '
          '${s.ageInDays(referenceDate)} дн. тому',
  ];
}
