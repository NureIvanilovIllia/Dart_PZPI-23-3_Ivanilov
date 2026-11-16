/// Формат держномера: регіон (дві літери), номер (чотири цифри), серія
/// (дві літери).
final plateFormat = RegExp(
  r'^(?<region>[A-Z]{2})(?<number>\d{4})(?<series>[A-Z]{2})$',
);

/// Символ, яким маскуються цифри номера.
const maskChar = '*';

final _digit = RegExp(r'\d');

/// Замінює цифри номера в [plate] зірочками, регіон і серію лишає.
///
/// Рядок, що не відповідає [plateFormat], повертається без змін.
String maskPlate(String plate) =>
    plateFormat.hasMatch(plate) ? plate.replaceAll(_digit, maskChar) : plate;
