import 'package:flutter_test/flutter_test.dart';
import 'package:trace_raffine/core/files/embroidery_file_policy.dart';

void main() {
  group('EmbroideryFilePolicy', () {
    test('accepts the required embroidery extensions', () {
      for (final fileName in <String>[
        'design.emb',
        'design.DST',
        'design.dhp',
        'design.DHE',
      ]) {
        expect(EmbroideryFilePolicy.isRejected(fileName), isFalse);
        expect(EmbroideryFilePolicy.isAccepted(fileName), isTrue);
      }
    });

    test('accepts other files with a clear extension', () {
      for (final fileName in <String>[
        'design.pes',
        'design.jef',
        'design.exp',
        'design.xxx',
      ]) {
        expect(EmbroideryFilePolicy.isRejected(fileName), isFalse);
        expect(EmbroideryFilePolicy.isAccepted(fileName), isTrue);
      }
    });

    test('rejects only files without an extension', () {
      expect(EmbroideryFilePolicy.isAccepted('design'), isFalse);
      expect(EmbroideryFilePolicy.isAccepted('design.'), isFalse);
    });
  });
}
