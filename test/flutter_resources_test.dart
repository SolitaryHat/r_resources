import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:r_resources/r_resources.dart';
import 'package:r_resources/src/class_gen/image_class_generator.dart';
import 'package:r_resources/src/resources_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Builder builder;

  setUp(() {
    builder = rResourcesBuilder(BuilderOptions.empty);
  });

  test('Generates nothing if pubspec not specify assets strategy', () async {
    final assetDescriptions = {
      'pkg|assets/images/ic_one.png': '123',
      'pkg|assets/fonts/noto_sans.oft': '456',
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
      'pkg|assets/fonts/noto_sans.oft': '456',
    };
    final imageClassGenerator = ImageClassGenerator(
      assetDescriptions.keys.map((e) => AssetId.parse(e)).toList(),
    );
    await testBuilder(
      builder,
      {
        'pkg|lib/main.dart': '',
        ...assetDescriptions,
        'pkg|pubspec.yaml': '''
flutter:
  assets:
    - assets/images/
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
          '}\n'
          '\n'
          '${imageClassGenerator.generate()}\n',
        ),
      },
    );
  });
}
