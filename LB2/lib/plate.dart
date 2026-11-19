/// Формат держномера: регіон (дві літери), номер (чотири цифри), серія
/// (дві літери).
final plateFormat = RegExp(
  r'^(?<region>[A-Z]{2})(?<number>\d{4})(?<series>[A-Z]{2})$',
);

/// Символ, яким маскуються цифри номера.
const maskChar = '*';

final _digit = RegExp(r'\d');

/// Методи для держномерів, записаних рядком.
extension PlateString on String {
  /// Рядок із зірочками замість цифр, якщо це держномер за [plateFormat].
  ///
  /// Будь-який інший рядок повертається без змін.
  String get masked =>
      plateFormat.hasMatch(this) ? replaceAll(_digit, maskChar) : this;
}
