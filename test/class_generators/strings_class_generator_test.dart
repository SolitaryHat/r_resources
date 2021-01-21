import 'package:flutter_test/flutter_test.dart';
import 'package:r_resources/src/class_gen/string_class_generator.dart';

void main() {
  group('StringsClassGenerator tests', () {
    test('Generates classes for simple strings', () async {
      final generator = StringsClassGenerator(
        localizationData: {
          'en_US': {
            'label_lorem_ipsum': 'Lorem ipsum',
            'label_color': 'Color',
          },
          'en_GB': {
            'label_lorem_ipsum': 'Lorem ipsum GB',
            'label_color': 'Colour',
          },
          'ru': {
            'label_color': 'Цвет',
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
      'label_lorem_ipsum': r'Lorem ipsum',
      'label_color': r'Color',
    },
    'en_GB': {
      'label_lorem_ipsum': r'Lorem ipsum GB',
      'label_color': r'Colour',
    },
    'ru': {
      'label_color': r'Цвет',
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
  });
}
