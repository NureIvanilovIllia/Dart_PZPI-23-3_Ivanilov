/// Вид виконаних робіт.
///
/// Ієрархія запечатана: усі підтипи оголошені в цьому файлі, тому `switch`
/// за [Work] перевіряється на повноту без гілки `default`.
sealed class Work {
  /// Назва робіт у журналі.
  final String name;

  /// Створює вид робіт із назвою [name].
  const Work(this.name);

  /// Повертає вид робіт за назвою [name].
  ///
  /// Для однієї назви завжди віддається той самий об’єкт із кешу. Невідома
  /// назва вважається діагностикою й теж потрапляє в кеш.
  factory Work.fromName(String name) =>
      _cache.putIfAbsent(name, () => Diagnostics(name));

  static final Map<String, Work> _cache = {for (final w in _known) w.name: w};

  /// Рекомендований інтервал до наступного такого обслуговування, км.
  int get intervalKm;

  /// Пробіг, на якому треба повторити ці роботи, якщо їх зроблено на
  /// пробігу [mileage].
  int nextServiceAt(int mileage) => mileage + intervalKm;
}

/// Гарантія на виконані роботи.
///
/// Обмеження `on Work` відкриває домішці [Work.name] і не дає підмішати
/// гарантію до класу поза ієрархією робіт.
mixin Warranty on Work {
  /// Тривалість гарантії в днях.
  int get warrantyDays;

  /// Чи діє гарантія, якщо роботи виконано [ageInDays] днів тому.
  bool covers(int ageInDays) => ageInDays <= warrantyDays;

  /// Рядок про залишок гарантії на ці роботи.
  String describe(int ageInDays) =>
      '$name – гарантія ще ${warrantyDays - ageInDays} дн.';
}

/// Заміна вузла або витратного матеріалу.
final class Replacement extends Work with Warranty {
  /// Створює заміну з назвою [name].
  const Replacement(super.name);

  @override
  int get intervalKm => 15000;

  @override
  int get warrantyDays => 180;
}

/// Діагностика без заміни деталей.
final class Diagnostics extends Work {
  /// Створює діагностику з назвою [name].
  const Diagnostics(super.name);

  @override
  int get intervalKm => 10000;
}

/// Робота з шинами й підвіскою.
final class TyreService extends Work with Warranty {
  /// Створює шинну роботу з назвою [name].
  const TyreService(super.name);

  @override
  int get intervalKm => 20000;

  @override
  int get warrantyDays => 30;
}

const _known = <Work>[
  Replacement('Заміна масла'),
  Replacement('Заміна гальмівних колодок'),
  Replacement('Заміна ременя ГРМ'),
  Diagnostics('Діагностика'),
  TyreService('Шиномонтаж'),
  TyreService('Розвал-сходження'),
];

/// Категорія робіт для звітів.
///
/// Домішка [Warranty] оголошена з `on Work`, тому сама є підтипом [Work] і
/// `switch` має її покрити. Після [TyreService] серед типів із гарантією
/// лишається тільки [Replacement].
String categoryOf(Work work) => switch (work) {
  Diagnostics() => 'діагностика',
  TyreService() => 'шини',
  Warranty() => 'заміна вузлів',
};
