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

/// Заміна вузла або витратного матеріалу.
final class Replacement extends Work {
  /// Створює заміну з назвою [name].
  const Replacement(super.name);

  @override
  int get intervalKm => 15000;
}

/// Діагностика без заміни деталей.
final class Diagnostics extends Work {
  /// Створює діагностику з назвою [name].
  const Diagnostics(super.name);

  @override
  int get intervalKm => 10000;
}

/// Робота з шинами й підвіскою.
final class TyreService extends Work {
  /// Створює шинну роботу з назвою [name].
  const TyreService(super.name);

  @override
  int get intervalKm => 20000;
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
String categoryOf(Work work) => switch (work) {
  Replacement() => 'заміна вузлів',
  Diagnostics() => 'діагностика',
  TyreService() => 'шини',
};
