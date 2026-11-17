/// Виконавець робіт.
enum Contractor {
  /// СТО Мотор.
  motor('СТО Мотор'),

  /// АвтоЛідер.
  autoLeader('АвтоЛідер'),

  /// Гараж-24.
  garage24('Гараж-24'),

  /// Шинний центр.
  tyreCenter('Шинний центр');

  /// Назва виконавця в журналі.
  final String title;

  /// Створює виконавця з назвою [title].
  const Contractor(this.title);

  static final Map<String, Contractor> _byTitle = {
    for (final c in values) c.title: c,
  };

  /// Знаходить виконавця за назвою [title]; для невідомої назви повертає
  /// `null`.
  static Contractor? byTitle(String title) => _byTitle[title];
}
