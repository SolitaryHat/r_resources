import 'package:flutter_test/flutter_test.dart';
import 'package:r_resources/src/class_gen/string_class_generator.dart';

void main() {
  group('StringsClassGenerator tests', () {
    test('Generates classes for string resources', () async {
      final generator = StringsClassGenerator(
        localizationData: {
          'en_US': {
            'label_lorem_ipsum': 'Lorem ipsum',
            'label_color': 'Color',
            'format_example': r'Your object is ${object} and other is ${other}',
            'label_with_newline': "HELLO!\nI'm new line symbol (\\n)"
          },
          'en_GB': {
            'label_lorem_ipsum': 'Lorem ipsum GB',
            'label_color': 'Colour',
          },
          'ru': {
            'label_color': 'Цвет',
            'format_example': r'Ты передал object = ${object}'
          },
        },
        supportedLocales: ['en_US', 'en_GB', 'ru'],
        fallbackLocale: 'en_US',
      );
      expect(
        await generator.generate(),
        '''class ${generator.className} {
  const ${generator.className}(this._locale);

  static const _fallbackLocale = Locale('en', 'US');
  final Locale _locale;

  static ${generator.className} of(BuildContext context) {
    return Localizations.of<${generator.className}>(context, ${generator.className});
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en_US': {
      'label_lorem_ipsum': 'Lorem ipsum',
      'label_color': 'Color',
      'format_example': 'Your object is \\\${object} and other is \\\${other}',
      'label_with_newline': 'HELLO!\\nI\\'m new line symbol (\\\\n)',
    },
    'en_GB': {
      'label_lorem_ipsum': 'Lorem ipsum GB',
      'label_color': 'Colour',
    },
    'ru': {
      'label_color': 'Цвет',
      'format_example': 'Ты передал object = \\\${object}',
    },
  };

  String _getString(String code) {
    return _localizedValues[_locale.toString()][code] ??
        _localizedValues[_fallbackLocale.toString()][code] ??
        code;
  }

  /// 'Lorem ipsum'
  String get label_lorem_ipsum => _getString('label_lorem_ipsum');

  /// 'Color'
  String get label_color => _getString('label_color');

  /// 'Your object is \\\${object} and other is \\\${other}'
  String format_example({
    Object object,
    Object other,
  }) {
    final rawString = _getString('format_example');
    return rawString
        .replaceAll(r'\${object}', object.toString())
        .replaceAll(r'\${other}', other.toString());
  }

  /// 'HELLO!\\nI\\\'m new line symbol (\\\\n)'
  String get label_with_newline => _getString('label_with_newline');
}

class RStringsDelegate extends LocalizationsDelegate<${generator.className}> {
  const RStringsDelegate();

  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('en', 'GB'),
    Locale('ru'),
  ];

  static const fallbackLocale = Locale('en', 'US');

  @override
  bool isSupported(Locale locale) => supportedLocales.contains(locale);

  @override
  Future<${generator.className}> load(Locale locale) async {
    return ${generator.className}(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<${generator.className}> old) => false;
}''',
      );
    });

    test('createGetterForTranslation generates simple strings getter', () {
      final generator = StringsClassGenerator(
        localizationData: {},
        supportedLocales: [],
        fallbackLocale: '',
      );

      expect(
        generator.createGetterForTranslation(
          'label_lorem_ipsum',
          'Lorem Ipsum',
        ),
        '  String get label_lorem_ipsum => _getString(\'label_lorem_ipsum\');',
      );
    });

    test('createGetterForTranslation generates format string', () {
      final generator = StringsClassGenerator(
        localizationData: {},
        supportedLocales: [],
        fallbackLocale: '',
      );

      expect(
        generator.createGetterForTranslation(
          'format_example',
          r'Your object is ${object} and other is ${other}',
        ),
        r'''  String format_example({
    Object object,
    Object other,
  }) {
    final rawString = _getString('format_example');
    return rawString
        .replaceAll(r'${object}', object.toString())
        .replaceAll(r'${other}', other.toString());
  }''',
      );
    });
  });
}
