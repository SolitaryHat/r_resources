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
    final stringsClass = _generateStringsClass();
    final delegateClass = _generateDelegateClass();
    return '$stringsClass\n\n$delegateClass';
  }

  String _generateStringsClass() {
    final classBuffer = StringBuffer()
      ..writeln('class $className {')
      ..writeln('  $className(this._locale);')
      ..writeln()
      ..writeln('  static const _fallbackLocale = '
          '${_createLocaleSourceCode(_fallbackLocale)};')
      ..writeln('  final Locale _locale;')
      ..writeln()
      ..writeln('  static $className of(BuildContext context) {')
      ..writeln('    return Localizations.of<$className>(context, $className);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  static const Map<String, Map<String, String>> '
          '_localizedValues = {');

    _localizationData.forEach((locale, localizedStrings) {
      classBuffer.writeln('    \'$locale\': {');
      localizedStrings.forEach((key, value) {
        classBuffer.writeln('      \'$key\': r\'$value\',');
      });
      classBuffer.writeln('    },');
    });

    classBuffer
      ..writeln('  };')
      ..writeln()
      ..writeln('  String _getString(String code) {')
      ..writeln('    return _localizedValues[_locale.toString()][code] ??')
      ..writeln('        _localizedValues[_fallbackLocale.toString()][code] ??')
      ..writeln('        code;')
      ..writeln('  }');

    final fallbackLocaleTranslations = _localizationData[_fallbackLocale];
    if (fallbackLocaleTranslations == null) {
      throw Exception('Fallback translations not found');
    }

    fallbackLocaleTranslations.forEach((key, value) {
      classBuffer
        ..writeln()
        ..writeln('  /// \'$value\'')
        ..writeln('  String get $key => _getString(\'$key\');');
    });

    classBuffer.write('}');

    return classBuffer.toString();
  }

  String _generateDelegateClass() {
    final classBuffer = StringBuffer();
    classBuffer
      ..writeln(
          'class RStringsDelegate extends LocalizationsDelegate<$className> {')
      ..writeln('  const RStringsDelegate();')
      ..writeln()
      ..writeln('  static const supportedLocales = [');

    for (final localeAsString in _supportedLocales) {
      classBuffer.writeln('    ${_createLocaleSourceCode(localeAsString)},');
    }

    classBuffer
      ..writeln('  ];')
      ..writeln()
      ..writeln('  static const fallbackLocale = '
          '${_createLocaleSourceCode(_fallbackLocale)};')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  bool isSupported(Locale locale) => '
          'supportedLocales.contains(locale);')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  Future<$className> load(Locale locale) async {')
      ..writeln('    return $className(locale);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  bool shouldReload(covariant '
          'LocalizationsDelegate<_Strings> old) => false;')
      ..write('}');

    return classBuffer.toString();
  }

  String _createLocaleSourceCode(String localeName) {
    final parts = localeName.split('_');
    switch (parts.length) {
      case 1:
        return 'Locale(\'${parts[0]}\')';
      case 2:
        return 'Locale(\'${parts[0]}\', \'${parts[1]}\')';
      default:
        throw Exception('Wrong locale name ($localeName)');
    }
  }
}
