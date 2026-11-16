import 'service.dart';

/// Роздільник полів у вхідному рядку.
const fieldSeparator = ';';

/// Довжина дати у форматі РРРР-ММ-ДД.
const isoDateLength = 10;

/// Розбирає дату [text] у форматі РРРР-ММ-ДД.
///
/// Повертає `null` і для неіснуючих дат: [DateTime.tryParse] переносить їх
/// на інший день (“2026-02-30” стає 2 березня), тому дата збирається назад
/// у текст і порівнюється з вхідним рядком.
DateTime? parseDate(String text) {
  final date = DateTime.tryParse(text);
  if (date == null) return null;
  return date.toIso8601String().substring(0, isoDateLength) == text
      ? date
      : null;
}

/// Розбирає рядок [line] у запис про обслуговування.
///
/// Повертає `null`, якщо полів не шість, пробіг чи вартість не є числами
/// або дата не існує чи не відповідає формату РРРР-ММ-ДД.
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
    final date = parseDate(dateText);
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
