import 'dart:async';

import 'package:meta/meta.dart' show required;

import 'class_generator.dart';

class StringsClassGenerator implements ClassGenerator {
  const StringsClassGenerator({
    @required Map<String, Map<String, String>> localizationData,
    @required List<String> supportedLocales,
    @required String fallbackLocale,
  })  : assert(localizationData != null),
        assert(supportedLocales != null),
        assert(fallbackLocale != null),
        _localizationData = localizationData,
        _supportedLocales = supportedLocales,
        _fallbackLocale = fallbackLocale;

  final Map<String, Map<String, String>> _localizationData;
  final List<String> _supportedLocales;
  final String _fallbackLocale;

  @override
  String get className => '_Strings';

  @override
  FutureOr<String> generate() {
    final classBuffer = StringBuffer()
      ..writeln('class $className {')
      ..writeln('  $className(this._locale, this._fallbackLocale);')
      ..writeln()
      ..writeln('  final Locale _locale;')
      ..writeln('  final _fallbackLocale = '
          '${_createLocaleSourceCode(_fallbackLocale)};')
      ..writeln()
      ..writeln('  static $className of(BuildContext context) {')
      ..writeln('    return Localizations.of<$className>(context, $className);')
      ..writeln('  }')
      ..writeln()
      ..writeln();

    return classBuffer.toString();
  }

  String _createLocaleSourceCode(String localeName) {
    final parts = localeName.split('_');
    switch (parts.length) {
      case 1:
        return 'Locale(${parts[0]})';
      case 2:
        return 'Locale(${parts[0]}, ${parts[1]})';
      default:
        throw Exception('Wrong locale name');
    }
  }
}

/*
class _Strings {
  _Strings(this._locale, this._fallbackLocale);

  final Locale _locale;
  final Locale _fallbackLocale;

  static _Strings of(BuildContext context) {
    return Localizations.of<_Strings>(context, _Strings);
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en_US': {
      'label_lorem_ipsum': r'Lorem ipsum',
      'label_hello': r'Color',
    },
    'en_GB': {
      'label_lorem_ipsum': r'Other lorem ipsum',
      'label_hello': r'Colour',
    },
    'ru': {
      'label_hello': r'Цвет',
    },
  };

  String _getString(String code) {
    return _localizedValues[_locale.toString()][code] ??
        _localizedValues[_fallbackLocale.toString()][code] ??
        code;
  }

  /// 'Lorem ipsum'
  String get label_lorem_ipsum => _getString('label_lorem_ipsum');

  String get label_hello => _getString('label_hello');
}

class RStringsDelegate extends LocalizationsDelegate<_Strings> {
  const RStringsDelegate({
    @required List<Locale> supportedLocales,
    @required Locale fallbackLocale,
  })  : assert(supportedLocales != null),
        assert(fallbackLocale != null),
        _supportedLocales = supportedLocales,
        _fallbackLocale = fallbackLocale;

  final List<Locale> _supportedLocales;
  final Locale _fallbackLocale;

  @override
  bool isSupported(Locale locale) =>
      _supportedLocales.contains(locale);

  @override
  Future<_Strings> load(Locale locale) async {
      print(locale);
      return _Strings(locale, _fallbackLocale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<_Strings> old) => false;
}


*/
