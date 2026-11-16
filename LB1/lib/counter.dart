/// Лічильник на замиканні: [tick] збільшує приховану змінну, [value] її читає.
({void Function() tick, int Function() value}) makeCounter() {
  var count = 0;
  return (tick: () => count++, value: () => count);
}
