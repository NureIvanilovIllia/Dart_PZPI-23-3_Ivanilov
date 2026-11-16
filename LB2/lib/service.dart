import 'plate.dart';

/// Роздільник полів у вхідному рядку.
const fieldSeparator = ';';

/// Довжина дати у форматі РРРР-ММ-ДД.
const isoDateLength = 10;

/// Фіксована “поточна” дата, щоб вивід програми не залежав від дня запуску.
final referenceDate = DateTime(2026, 11, 7);

/// Один запис про технічне обслуговування автомобіля.
class Service {
  /// Держномер автомобіля.
  final String plate;

  /// Тип виконаних робіт.
  final String workType;

  /// Пробіг автомобіля в кілометрах.
  final int mileage;

  /// Дата виконання робіт.
  final DateTime date;

  /// Вартість робіт.
  final double cost;

  /// Виконавець робіт.
  final String contractor;

  /// Створює запис із вже розібраних значень.
  const Service({
    required this.plate,
    required this.workType,
    required this.mileage,
    required this.date,
    required this.cost,
    required this.contractor,
  });

  /// Розбирає рядок [line] формату
  /// `держномер;тип робіт;пробіг;дата;вартість;виконавець`.
  ///
  /// Для пошкодженого рядка кидає [FormatException]; якщо виняток не
  /// потрібен, див. [tryParse].
  factory Service.fromCsv(String line) =>
      tryParse(line) ??
      (throw FormatException('Некоректний рядок журналу', line));

  /// Розбирає рядок [line] так само, як [Service.fromCsv].
  ///
  /// Повертає `null`, якщо полів не шість, пробіг чи вартість не є числами
  /// або дата не існує чи не відповідає формату РРРР-ММ-ДД.
  static Service? tryParse(String line) {
    final parts = line
        .split(fieldSeparator)
        .map((part) => part.trim())
        .toList();
    if (parts case [
      final plate,
      final workType,
      final mileageText,
      final dateText,
      final costText,
      final contractor,
    ]) {
      final mileage = int.tryParse(mileageText);
      final date = _parseDate(dateText);
      final cost = double.tryParse(costText);
      if (mileage == null || date == null || cost == null) return null;

      return Service(
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

  /// Перелік порушень діапазонів у записі.
  ///
  /// Порожній список означає, що запис коректний.
  List<String> get violations => [
    if (!plateFormat.hasMatch(plate)) 'невірний формат держномера',
    if (mileage < 0) 'пробіг менший за нуль',
    if (cost <= 0) 'вартість не додатна',
    if (date.isAfter(referenceDate)) 'дата з майбутнього',
  ];

  /// Чи запис пройшов перевірку діапазонів.
  bool get isValid => violations.isEmpty;

  /// Вік запису в днях відносно дати [reference].
  int ageInDays(DateTime reference) =>
      _day(reference).difference(_day(date)).inDays;

  @override
  String toString() =>
      'Service($plate, $workType, $mileage км, ${_isoDate(date)}, '
      '${cost.toStringAsFixed(2)}, $contractor)';
}

String _isoDate(DateTime date) =>
    date.toIso8601String().substring(0, isoDateLength);

DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// [DateTime.tryParse] переносить неіснуючі дати на інший день
/// (“2026-02-30” стає 2 березня), тому дата збирається назад у текст
/// і порівнюється з вхідним рядком.
DateTime? _parseDate(String text) {
  final date = DateTime.tryParse(text);
  return date != null && _isoDate(date) == text ? date : null;
}
