import 'package:fleet_service/plate.dart';
import 'package:fleet_service/report.dart';
import 'package:fleet_service/repository.dart';
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

  test('masked ховає цифри держномера, інші рядки лишає', () {
    expect('AX1234BC'.masked, 'AX****BC');
    expect('ZZ99'.masked, 'ZZ99');
  });

  test('гарантія є в заміни й шин, але не в діагностики', () {
    expect(Work.fromName('Заміна масла'), isA<Warranty>());
    expect(Work.fromName('Діагностика'), isNot(isA<Warranty>()));
    expect(
      Work.fromName('Шиномонтаж'),
      isA<Warranty>().having((w) => w.covers(30), 'covers(30)', isTrue),
    );
  });

  test('costClass розбирає вартість і вид робіт разом', () {
    Service at(String work, String cost) =>
        Service.fromCsv('AX1234BC;$work;1;2026-03-14;$cost;СТО Мотор');
    expect(costClass(at('Діагностика', '600')), 'дешева');
    expect(costClass(at('Заміна масла', '1850.50')), 'звичайна');
    expect(costClass(at('Заміна масла', '3200')), 'дорога з гарантією');
    expect(costClass(at('Діагностика', '3200')), 'дорога');
  });

  test('сховище знаходить запис за id', () {
    final service = Service.fromCsv(line);
    final repo = Repository<Service>()..add(service);
    expect(repo.findById(service.id), service);
    expect(repo.findById('немає'), isNull);
  });
}
