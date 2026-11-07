import 'service.dart';

/// Роздільник полів у вхідному рядку.
const fieldSeparator = ';';

/// Кількість полів у рядку журналу.
const fieldCount = 6;

/// Розбирає рядок [line] у запис про обслуговування.
///
/// Повертає `null`, якщо полів не шість, пробіг чи вартість не є числами
/// або дата не відповідає формату ISO 8601.
Service? parseLine(String line) {
  final parts = line.split(fieldSeparator).map((part) => part.trim()).toList();
  if (parts.length != fieldCount) return null;

  final mileage = int.tryParse(parts[2]);
  final date = DateTime.tryParse(parts[3]);
  final cost = double.tryParse(parts[4]);
  if (mileage == null || date == null || cost == null) return null;

  return (
    plate: parts[0],
    workType: parts[1],
    mileage: mileage,
    date: date,
    cost: cost,
    contractor: parts[5],
  );
}
