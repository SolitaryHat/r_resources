// ignore: import_of_legacy_library_into_null_safe
import 'package:build/build.dart';
import 'package:r_resources/src/class_gen/image_asset_class_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';

void main() {
  group('ImageAssetClassGenerator tests', () {
    test('Empty images class for empty assets', () async {
      final generator = ImageAssetClassGenerator([]);
      expect(
        await generator.generate(),
        'class ${generator.className} {\n'
        '  const ${generator.className}();\n'
        '}',
      );
    });

    test('Empty images class for incorrect assets folder', () async {
      final generator = ImageAssetClassGenerator([
        AssetId('pkg', 'assets/ic_one.png'),
        AssetId('pkg', 'assets/img/ic_one.png'),
        AssetId('pkg', 'assets/drawable/ic_one.png'),
        AssetId('pkg', 'ic_one.png'),
        AssetId('pkg', 'assets/image/ic_one.png'),
      ]);
      expect(
        await generator.generate(),
        'class ${generator.className} {\n'
        '  const ${generator.className}();\n'
        '}',
      );
    });

    test('Images class contains references to assets/images folder', () async {
      final generator = ImageAssetClassGenerator([
        AssetId('pkg', 'assets/images/ic_one.png'),
        AssetId('pkg', 'assets/images/ic_two.png'),
        AssetId('pkg', 'assets/images/ic_three.png'),
      ]);
      expect(
        await generator.generate(),
        'class ${generator.className} {\n'
        '  const ${generator.className}();\n'
        '\n'
        '  /// ![](${absolute('assets/images/ic_one.png')})\n'
        '  final ic_one = r\'assets/images/ic_one.png\';\n'
        '\n'
        '  /// ![](${absolute('assets/images/ic_two.png')})\n'
        '  final ic_two = r\'assets/images/ic_two.png\';\n'
        '\n'
        '  /// ![](${absolute('assets/images/ic_three.png')})\n'
        '  final ic_three = r\'assets/images/ic_three.png\';\n'
        '}',
      );
    });

    test('Replaces invalid dart characters in file name', () async {
      final generator = ImageAssetClassGenerator([
        AssetId('pkg', 'assets/images/ic@one.png'),
        AssetId('pkg', 'assets/images/ic\$two.png'),
        AssetId('pkg', 'assets/images/ic!three.png'),
      ]);
      expect(
        await generator.generate(),
        'class ${generator.className} {\n'
        '  const ${generator.className}();\n'
        '\n'
        '  /// ![](${absolute('assets/images/ic@one.png')})\n'
        '  final ic_one = r\'assets/images/ic@one.png\';\n'
        '\n'
        '  /// ![](${absolute('assets/images/ic\$two.png')})\n'
        '  final ic_two = r\'assets/images/ic\$two.png\';\n'
        '\n'
        '  /// ![](${absolute('assets/images/ic!three.png')})\n'
        '  final ic_three = r\'assets/images/ic!three.png\';\n'
        '}',
      );
    });
  });
}
