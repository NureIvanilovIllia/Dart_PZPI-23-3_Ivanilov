/// Сутність, яка вміє повідомляти власний ідентифікатор.
abstract interface class Identifiable {
  /// Унікальний ідентифікатор сутності.
  String get id;
}

/// Сховище сутностей, які вміють повідомляти власний ідентифікатор.
///
/// Обмеження `T extends Identifiable` гарантує, що в кожного елемента є `id`,
/// тому сховище працює з будь-якою сутністю й не потребує приведення типів.
class Repository<T extends Identifiable> {
  final Map<String, T> _items = {};

  /// Додає [item]; елемент із таким самим `id` замінюється.
  void add(T item) => _items[item.id] = item;

  /// Повертає елемент за [id] або `null`.
  T? findById(String id) => _items[id];

  /// Повертає елементи, для яких [test] істинний.
  Iterable<T> where(bool Function(T) test) => _items.values.where(test);
}
