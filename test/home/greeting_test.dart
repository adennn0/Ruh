import 'package:flutter_test/flutter_test.dart';
import 'package:ruhun_parliyor/features/home/greeting.dart';

void main() {
  test('greeting follows local hour including the night boundary', () {
    expect(greetingFor(DateTime(2026, 1, 1, 2), null), 'İyi geceler ✨');
    expect(greetingFor(DateTime(2026, 1, 1, 5), null), 'Günaydın ✨');
    expect(greetingFor(DateTime(2026, 1, 1, 12), null), 'İyi günler ✨');
    expect(greetingFor(DateTime(2026, 1, 1, 18), null), 'İyi akşamlar ✨');
    expect(
        greetingFor(DateTime(2026, 1, 1, 22), ' Eren '), 'İyi geceler, Eren ✨');
  });
}
