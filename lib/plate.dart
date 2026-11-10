/// Формат держномера: регіон (дві літери), номер (чотири цифри), серія
/// (дві літери).
final plateFormat = RegExp(
  r'^(?<region>[A-Z]{2})(?<number>\d{4})(?<series>[A-Z]{2})$',
);

/// Символ, яким маскуються цифри номера.
const maskChar = '*';

/// Замінює цифри номера в [plate] зірочками, регіон і серію лишає.
String maskPlate(String plate) => plate.replaceAllMapped(plateFormat, (match) {
  // replaceAllMapped віддає Match, а namedGroup є лише в RegExpMatch.
  final m = match as RegExpMatch;
  final digits = maskChar * (m.namedGroup('number')?.length ?? 0);
  return '${m.namedGroup('region')}$digits${m.namedGroup('series')}';
});
