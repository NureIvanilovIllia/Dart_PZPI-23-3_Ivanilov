import 'service.dart';

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

/// Сортує за вартістю, а за однакової вартості – за пробігом.
///
/// Напрямок задає [descending]; вхідний список не змінюється.
List<Service> sortServices(List<Service> services, {bool descending = false}) {
  final sign = descending ? -1 : 1;
  return [...services]..sort((a, b) {
    final byCost = a.cost.compareTo(b.cost);
    return sign * (byCost != 0 ? byCost : a.mileage.compareTo(b.mileage));
  });
}

/// Збирає текстовий звіт.
///
/// [top] – скільки записів показати після сортування, [descending] – напрямок
/// сортування, [withGroups] – чи друкувати суми за типами робіт.
String buildReport(
  List<Service> services, {
  String title = 'Звіт про обслуговування',
  int top = 5,
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
  buffer.writeln('Записи за вартістю ($direction):');
  final sorted = sortServices(services, descending: descending).take(top);
  var number = 1;
  for (final s in sorted) {
    buffer.writeln(
      '  ${number++}. ${s.plate}, ${s.workType}, ${s.mileage} км, '
      '${s.cost.toStringAsFixed(2)}',
    );
  }
  return buffer.toString();
}
