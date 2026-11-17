import 'package:fleet_service/service.dart';
import 'package:fleet_service/work.dart';
import 'package:test/test.dart';

const line = 'AX1234BC;Заміна масла;152300;2026-03-14;1850.50;СТО Мотор';

void main() {
  test('однакові записи рівні й мають однаковий hashCode', () {
    final a = Service.fromCsv(line);
    final b = Service.fromCsv(line);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });

  test('множина з двох однакових записів має розмір 1', () {
    expect({Service.fromCsv(line), Service.fromCsv(line)}, hasLength(1));
  });

  test('tryParse відхиляє неіснуючу дату', () {
    expect(
      Service.tryParse('AX1234BC;Діагностика;1;2026-02-30;1.00;СТО Мотор'),
      isNull,
    );
  });

  test('fromCsv кидає FormatException на пошкодженому рядку', () {
    expect(() => Service.fromCsv('ZZ99;Діагностика'), throwsFormatException);
  });

  test('Work.fromName віддає один і той самий об’єкт для однієї назви', () {
    expect(Work.fromName('Шиномонтаж'), same(Work.fromName('Шиномонтаж')));
    expect(Work.fromName('Шиномонтаж'), isA<TyreService>());
  });

  test('наступне обслуговування залежить від підтипу', () {
    expect(Work.fromName('Заміна масла').nextServiceAt(152300), 167300);
    expect(categoryOf(Work.fromName('Діагностика')), 'діагностика');
  });
}
