import 'service.dart';

/// Сума вартості робіт дорожчих за [threshold].
double expensiveTotal(List<Service> services, double threshold) => services
    .where((s) => s.cost > threshold)
    .map((s) => s.cost)
    .fold(0.0, (sum, cost) => sum + cost);

/// Рядки "номер – тип робіт" для робіт дорожчих за [threshold].
List<String> expensiveLabels(List<Service> services, double threshold) =>
    services
        .where((s) => s.cost > threshold)
        .map((s) => '${s.plate} – ${s.workType}')
        .fold(<String>[], (list, label) => list..add(label));

/// Сума і середня вартість робіт виконавця [contractor].
({double total, double average}) contractorCosts(
  List<Service> services,
  String contractor,
) {
  final costs = services
      .where((s) => s.contractor == contractor)
      .map((s) => s.cost)
      .toList();
  final total = costs.fold(0.0, (sum, cost) => sum + cost);
  return (total: total, average: costs.isEmpty ? 0 : total / costs.length);
}
