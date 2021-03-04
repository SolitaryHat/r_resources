import 'dart:async';

import 'package:meta/meta.dart' show visibleForTesting;

import 'class_generator.dart';

class StringsClassGenerator implements ClassGenerator {
  const StringsClassGenerator({
    required Map<String, Map<String, String>> localizationData,
    required List<String> supportedLocales,
    required String fallbackLocale,
  })   : _localizationData = localizationData,
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
      ..writeln('  const $className(this.locale);')
      ..writeln()
      ..writeln('  static const _fallbackLocale = '
          '${_createLocaleSourceCode(_fallbackLocale)};')
      ..writeln('  final Locale locale;')
      ..writeln()
      ..writeln('  static $className of(BuildContext context) {')
      ..writeln(
        '    return Localizations.of<$className>(context, $className)!;',
      )
      ..writeln('  }')
      ..writeln()
      ..writeln('  static const Map<String, Map<String, String>> '
          '_localizedValues = {');

    _localizationData.forEach((locale, localizedStrings) {
      classBuffer.writeln('    \'$locale\': {');
      localizedStrings.forEach((key, value) {
        classBuffer.writeln(
          '      \'$key\': \'${_replaceDartCharactersInString(value)}\',',
        );
      });
      classBuffer.writeln('    },');
    });

    classBuffer
      ..writeln('  };')
      ..writeln()
      ..writeln('  String _getString(String code) {')
      ..writeln('    return _localizedValues[locale.toString()]?[code] ??')
      ..writeln(
        '        _localizedValues[_fallbackLocale.toString()]?[code] ??',
      )
      ..writeln('        code;')
      ..writeln('  }');

    final fallbackLocaleTranslations = _localizationData[_fallbackLocale];
    if (fallbackLocaleTranslations == null) {
      throw Exception('Fallback translations not found');
    }

    fallbackLocaleTranslations.forEach((key, value) {
      classBuffer
        ..writeln()
        ..writeln('  /// \'${_replaceDartCharactersInString(value)}\'')
        ..writeln('${createGetterForTranslation(key, value)}');
    });

    classBuffer.write('}');

    return classBuffer.toString();
  }

  String _replaceDartCharactersInString(String string) {
    return string
        .replaceAll('\\', '\\\\')
        .replaceAll('\n', '\\n')
        .replaceAll('\'', '\\\'')
        .replaceAll('\$', '\\\$');
  }

  @visibleForTesting
  String createGetterForTranslation(
    String translationKey,
    String rawTranslationValue,
  ) {
    final stringFormatRegexp = RegExp(r'\$\{([^}]+)\}');
    final stringFormatMatches =
        stringFormatRegexp.allMatches(rawTranslationValue);

    if (stringFormatMatches.isEmpty) {
      return '  String get $translationKey => '
          '_getString(\'$translationKey\');';
    }

    final formatParams = <String, String>{};
    for (final match in stringFormatMatches) {
      final fullMatch = match.group(0)!;
      final groupMatch = match.group(1)!;
      formatParams[fullMatch] = groupMatch;
    }

    final getterBuffer = StringBuffer()..writeln('  String $translationKey({');
    formatParams.forEach((fullMatch, paramName) {
      getterBuffer.writeln('    required Object $paramName,');
    });
    getterBuffer
      ..writeln('  }) {')
      ..writeln('    final rawString = _getString(\'$translationKey\');')
      ..write('    return rawString');
    formatParams.forEach((fullMatch, paramName) {
      getterBuffer.write(
        '\n        .replaceAll'
        '(r\'$fullMatch\', $paramName.toString())',
      );
    });
    getterBuffer
      ..writeln(';')
      ..write('  }');

    return getterBuffer.toString();
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
