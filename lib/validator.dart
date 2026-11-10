import 'plate.dart';
import 'service.dart';

/// Фіксована "поточна" дата, щоб вивід програми не залежав від дня запуску.
final referenceDate = DateTime(2026, 11, 7);

/// Повертає перелік порушень діапазонів у записі [s].
///
/// Порожній список означає, що запис коректний.
List<String> violations(Service s) => [
  if (!plateFormat.hasMatch(s.plate)) 'невірний формат держномера',
  if (s.mileage < 0) 'пробіг менший за нуль',
  if (s.cost <= 0) 'вартість не додатна',
  if (s.date.isAfter(referenceDate)) 'дата з майбутнього',
];
