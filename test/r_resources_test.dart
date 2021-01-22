import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:r_resources/r_resources.dart';
import 'package:r_resources/src/class_gen/font_class_generator.dart';
import 'package:r_resources/src/class_gen/image_asset_class_generator.dart';
import 'package:r_resources/src/class_gen/string_class_generator.dart';
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
        'pkg|assets/strings/en.json': '''
{
  "label_test": "test"
}
        ''',
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
      final optionsFile = File('r_options.yaml')
        ..createSync()
        ..writeAsStringSync('''
supported_locales:
  - en_US
  - en_GB
  - ru

fallback_locale: en_US
          ''');

      final assetDescriptions = {
        'pkg|assets/images/ic_one.png': '123',
        'pkg|assets/fonts/NotoSans-Medium.ttf': '456',
        'pkg|assets/svg/ic_two.svg': '12455',
        'pkg|assets/strings/en_GB.json': '''{
    "label_lorem_ipsum": "Other lorem ipsum",
    "label_color": "Colour"
}''',
        'pkg|assets/strings/en_US.json': '''{
    "label_lorem_ipsum": "Lorem ipsum",
    "label_color": "Color"
}''',
        'pkg|assets/strings/ru.json': '''{
    "label_color": "Цвет"
}''',
      };
      final assets =
          assetDescriptions.keys.map((e) => AssetId.parse(e)).toList();

      /// Assumed that all generators are tested separatly
      /// and those generators are using correct data from assetDescriptions
      final imageClassGenerator = ImageAssetClassGenerator(assets);
      final svgClassGenerator = SvgAssetClassGenerator(assets);
      final fontClassGenerator = FontClassGenerator(assets);
      final stringsClassGenerator = StringsClassGenerator(
        localizationData: {
          'en_US': {
            'label_lorem_ipsum': 'Lorem ipsum',
            'label_color': 'Color',
          },
          'en_GB': {
            'label_lorem_ipsum': 'Other lorem ipsum',
            'label_color': 'Colour',
          },
          'ru': {
            'label_color': 'Цвет',
          },
        },
        supportedLocales: ['en_US', 'en_GB', 'ru'],
        fallbackLocale: 'en_US',
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
    - assets/svg/
    - assets/fonts/
''',
        },
        generateFor: {
          'pkg|lib/\$lib\$',
        },
        outputs: {
          'pkg|lib/r.dart': decodedMatches(
            '''$generatedFileHeader

$ignoreCommentForLinter

import 'package:flutter/material.dart';

class R {
  static const images = ${imageClassGenerator.className}();
  static const svg = ${svgClassGenerator.className}();
  static const fonts = ${fontClassGenerator.className}();
  static ${stringsClassGenerator.className} stringsOf(BuildContext context) => ${stringsClassGenerator.className}.of(context);
}

${imageClassGenerator.generate()}

${svgClassGenerator.generate()}

${fontClassGenerator.generate()}

${stringsClassGenerator.generate()}
''',
          ),
        },
      );

      optionsFile.deleteSync();
    });
  });
}
