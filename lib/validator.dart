import 'service.dart';

/// Формат держномера: дві літери, чотири цифри, дві літери.
final plateFormat = RegExp(r'^[A-Z]{2}\d{4}[A-Z]{2}$');

/// Фіксована "поточна" дата, щоб вивід програми не залежав від дня запуску.
final referenceDate = DateTime(2026, 11, 7);

/// Перевіряє діапазони значень запису [s].
bool isValid(Service s) =>
    plateFormat.hasMatch(s.plate) &&
    s.mileage >= 0 &&
    s.cost > 0 &&
    !s.date.isAfter(referenceDate);
