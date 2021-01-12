import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:r_resources/r_resources.dart';
import 'package:r_resources/src/class_gen/font_class_generator.dart';
import 'package:r_resources/src/class_gen/image_asset_class_generator.dart';
import 'package:r_resources/src/class_gen/svg_asset_class_generator.dart';
import 'package:r_resources/src/resources_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Builder builder;

  setUp(() {
    builder = rResourcesBuilder(BuilderOptions.empty);
  });

  group('General r_resources builder test', () {
    test('Generates nothing if pubspec not specify assets strategy', () async {
      final assetDescriptions = {
        'pkg|assets/images/ic_one.png': '123',
        'pkg|assets/fonts/NotoSans-Medium.ttf': '456',
        'pkg|assets/svg/ic_two.svg': '12455',
      };
      await testBuilder(
        builder,
        {
          ...assetDescriptions,
          'pkg|pubspec.yaml': '',
          'pkg|lib/main.dart': '',
        },
        generateFor: {
          'pkg|lib/\$lib\$',
        },
        outputs: {},
      );
    });

    test('Generates R', () async {
      final assetDescriptions = {
        'pkg|assets/images/ic_one.png': '123',
        'pkg|assets/fonts/NotoSans-Medium.ttf': '456',
        'pkg|assets/svg/ic_two.svg': '12455',
      };
      final assets =
          assetDescriptions.keys.map((e) => AssetId.parse(e)).toList();

      /// all generators are tested separatly
      final imageClassGenerator = ImageAssetClassGenerator(assets);
      final svgClassGenerator = SvgAssetClassGenerator(assets);
      final fontClassGenerator = FontClassGenerator(assets);

      await testBuilder(
        builder,
        {
          'pkg|lib/main.dart': '',
          ...assetDescriptions,
          'pkg|pubspec.yaml': '''
flutter:
  assets:
    - assets/images/
    - assets/svg/
    - assets/fonts/
''',
        },
        generateFor: {
          'pkg|lib/\$lib\$',
        },
        outputs: {
          'pkg|lib/r.dart': decodedMatches(
            '$generatedFileHeader\n'
            '\n'
            '$ignoreCommentForLinter\n'
            '\n'
            'class R {\n'
            '  static final images = ${imageClassGenerator.className}();\n'
            '  static final svg = ${svgClassGenerator.className}();\n'
            '  static final fonts = ${fontClassGenerator.className}();\n'
            '}\n'
            '\n'
            '${imageClassGenerator.generate()}\n'
            '\n'
            '${svgClassGenerator.generate()}\n'
            '\n'
            '${fontClassGenerator.generate()}\n',
          ),
        },
      );
    });
  });
}
