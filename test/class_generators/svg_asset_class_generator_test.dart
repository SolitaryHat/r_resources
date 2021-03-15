import 'package:build/build.dart';
import 'package:r_resources/src/class_gen/svg_asset_class_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';

void main() {
  group('SvgAssetClassGenerator tests', () {
    test('Empty images class for empty assets', () async {
      final generator = SvgAssetClassGenerator([]);
      expect(
        await generator.generate(),
        'class ${generator.className} {\n'
        '  const ${generator.className}();\n'
        '}',
      );
    });

    test('Empty svg class for incorrect assets folder', () async {
      final generator = SvgAssetClassGenerator([
        AssetId('pkg', 'assets/ic_one.svg'),
        AssetId('pkg', 'assets/vector/ic_one.svg'),
        AssetId('pkg', 'assets/drawable/ic_one.svg'),
        AssetId('pkg', 'ic_one.svg'),
        AssetId('pkg', 'assets/images/ic_one.svg'),
      ]);
      expect(
        await generator.generate(),
        'class ${generator.className} {\n'
        '  const ${generator.className}();\n'
        '}',
      );
    });

    test('Svg class contains references to assets/svg folder', () async {
      final generator = SvgAssetClassGenerator([
        AssetId('pkg', 'assets/svg/ic_one.svg'),
        AssetId('pkg', 'assets/svg/ic_two.svg'),
        AssetId('pkg', 'assets/svg/ic_three.svg'),
      ]);
      expect(
        await generator.generate(),
        'class ${generator.className} {\n'
        '  const ${generator.className}();\n'
        '\n'
        '  /// ![](${absolute('assets/svg/ic_one.svg')})\n'
        '  final ic_one = r\'assets/svg/ic_one.svg\';\n'
        '\n'
        '  /// ![](${absolute('assets/svg/ic_two.svg')})\n'
        '  final ic_two = r\'assets/svg/ic_two.svg\';\n'
        '\n'
        '  /// ![](${absolute('assets/svg/ic_three.svg')})\n'
        '  final ic_three = r\'assets/svg/ic_three.svg\';\n'
        '}',
      );
    });

    test('Replaces invalid dart characters in file name', () async {
      final generator = SvgAssetClassGenerator([
        AssetId('pkg', 'assets/svg/ic@one.svg'),
        AssetId('pkg', 'assets/svg/ic\$two.svg'),
        AssetId('pkg', 'assets/svg/ic!three.svg'),
      ]);
      expect(
        await generator.generate(),
        'class ${generator.className} {\n'
        '  const ${generator.className}();\n'
        '\n'
        '  /// ![](${absolute('assets/svg/ic@one.svg')})\n'
        '  final ic_one = r\'assets/svg/ic@one.svg\';\n'
        '\n'
        '  /// ![](${absolute('assets/svg/ic\$two.svg')})\n'
        '  final ic_two = r\'assets/svg/ic\$two.svg\';\n'
        '\n'
        '  /// ![](${absolute('assets/svg/ic!three.svg')})\n'
        '  final ic_three = r\'assets/svg/ic!three.svg\';\n'
        '}',
      );
    });
  });
}
