import 'service.dart';

/// Роздільник полів у вхідному рядку.
const fieldSeparator = ';';

/// Розбирає рядок [line] у запис про обслуговування.
///
/// Повертає `null`, якщо полів не шість, пробіг чи вартість не є числами
/// або дата не відповідає формату ISO 8601.
Service? parseLine(String line) {
  final parts = line.split(fieldSeparator).map((part) => part.trim()).toList();
  if (parts case [
    final plate,
    final workType,
    final mileageText,
    final dateText,
    final costText,
    final contractor,
  ]) {
    final mileage = int.tryParse(mileageText);
    final date = DateTime.tryParse(dateText);
    final cost = double.tryParse(costText);
    if (mileage == null || date == null || cost == null) return null;

    return (
      plate: plate,
      workType: workType,
      mileage: mileage,
      date: date,
      cost: cost,
      contractor: contractor,
    );
  }
  return null;
}
