import 'package:build/build.dart';
import 'package:r_resources/src/class_gen/font_class_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FontClassGenerator tests', () {
    test('Empty fonts class for empty assets', () async {
      final generator = FontClassGenerator([]);
      expect(
        await generator.generate(),
        'class ${generator.className} {\n'
        '  const ${generator.className}();\n'
        '}',
      );
    });

    test('Empty fonts class for incorrect assets folder', () async {
      final generator = FontClassGenerator([
        AssetId('pkg', 'assets/NotoSans-Medium.ttf'),
        AssetId('pkg', 'assets/font/NotoSans-Medium.ttf'),
        AssetId('pkg', 'NotoSans-Medium.ttf'),
      ]);
      expect(
        await generator.generate(),
        'class ${generator.className} {\n'
        '  const ${generator.className}();\n'
        '}',
      );
    });

    test('Fonts class contains references to assets/fonts folder', () async {
      final generator = FontClassGenerator([
        AssetId('pkg', 'assets/fonts/NotoSans-Medium.ttf'),
        AssetId('pkg', 'assets/fonts/Roboto-Regular.oft'),
      ]);
      expect(
        await generator.generate(),
        'class ${generator.className} {\n'
        '  const ${generator.className}();\n'
        '\n'
        '  final noto_sans_medium = r\'assets/fonts/NotoSans-Medium.ttf\';\n'
        '\n'
        '  final roboto_regular = r\'assets/fonts/Roboto-Regular.oft\';\n'
        '}',
      );
    });

    test('Replaces invalid dart characters in file name', () async {
      final generator = FontClassGenerator([
        AssetId('pkg', 'assets/fonts/NotoSans-Medium.ttf'),
        AssetId('pkg', 'assets/fonts/Roboto@Regular.oft'),
      ]);
      expect(
        await generator.generate(),
        'class ${generator.className} {\n'
        '  const ${generator.className}();\n'
        '\n'
        '  final noto_sans_medium = r\'assets/fonts/NotoSans-Medium.ttf\';\n'
        '\n'
        '  final roboto_regular = r\'assets/fonts/Roboto@Regular.oft\';\n'
        '}',
      );
    });
  });
}
