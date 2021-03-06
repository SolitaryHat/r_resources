import 'dart:async';
import 'dart:convert';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart' show visibleForTesting;
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'class_gen/font_class_generator.dart';
import 'class_gen/image_asset_class_generator.dart';
import 'class_gen/string_class_generator.dart';
import 'class_gen/svg_asset_class_generator.dart';
import 'utils.dart';

const _defaultGeneratedClassPath = 'lib';
const _defaultSupportedLocales = ['en'];
const _defaultFallbackLocale = 'en';
const _defaultSourceFilesDirName = 'lib/';
const _optionsFileName = 'r_options.yaml';
const _pubspecFileName = 'pubspec.yaml';

@visibleForTesting
const generatedFileHeader =
    '/// THIS FILE IS GENERATED BY r_resources. DO NOT MODIFY MANUALLY.';

@visibleForTesting
const ignoreCommentForLinter = '// ignore_for_file: '
    'avoid_classes_with_only_static_members,'
    'always_specify_types,'
    'lines_longer_than_80_chars,'
    'non_constant_identifier_names,'
    'prefer_double_quotes,'
    'unnecessary_raw_strings,'
    'use_raw_strings';

class _GeneratorOptions {
  const _GeneratorOptions._({
    this.path = _defaultGeneratedClassPath,
    this.supportedLocales = _defaultSupportedLocales,
    this.fallbackLocale = _defaultFallbackLocale,
  });

  factory _GeneratorOptions() => const _GeneratorOptions._();

  factory _GeneratorOptions.fromYamlMap(YamlMap yamlMap) {
    final path = yamlMap['path'] as String?;
    final supportedLocalesYamlList = yamlMap['supported_locales'] as YamlList?;
    final supportedLocales = supportedLocalesYamlList == null
        ? null
        : List<String>.from(supportedLocalesYamlList);
    final fallbackLocale = yamlMap['fallback_locale'] as String?;
    return _GeneratorOptions._(
      path: path ?? _defaultGeneratedClassPath,
      supportedLocales: supportedLocales ?? _defaultSupportedLocales,
      fallbackLocale: fallbackLocale ?? _defaultFallbackLocale,
    );
  }

  final String path;
  final List<String> supportedLocales;
  final String fallbackLocale;

  bool get isPathCorrect =>
      path == _defaultGeneratedClassPath ||
      path.startsWith(_defaultSourceFilesDirName);
}

class ResourcesBuilder implements Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final pubspecYamlMap = await _createPubspecYampMap(buildStep);
    if (pubspecYamlMap?.isEmpty ?? true) return;

    final options = _generatorOptions;
    if (!options.isPathCorrect) {
      log.severe(
        'Overriden path from $_optionsFileName should start with "lib/"',
      );
      return;
    }

    final rClass = await _generateRFileContent(
      buildStep,
      pubspecYamlMap!,
      options,
    );
    if (rClass.isEmpty) return;

    final dir = options.path.startsWith('lib') ? options.path : 'lib';
    final output = AssetId(
      buildStep.inputId.package,
      path.join(dir, 'r.dart'),
    );
    return buildStep.writeAsString(output, rClass);
  }

  @override
  Map<String, List<String>> get buildExtensions {
    final options = _generatorOptions;
    var extensions = 'r.dart';
    if (options.path != _defaultGeneratedClassPath && options.isPathCorrect) {
      extensions =
          '${options.path.replaceFirst(_defaultSourceFilesDirName, '')}'
          '/$extensions';
    }
    return {
      r'$lib$': [
        extensions,
      ]
    };
  }

  _GeneratorOptions get _generatorOptions {
    final optionsFile = File(_optionsFileName);

    if (optionsFile.existsSync()) {
      final optionsAsString = optionsFile.readAsStringSync();
      if (optionsAsString.isNotEmpty) {
        return _GeneratorOptions.fromYamlMap(
          loadYaml(optionsAsString) as YamlMap,
        );
      }
    }

    return _GeneratorOptions();
  }

  Future<YamlMap?> _createPubspecYampMap(BuildStep buildStep) async {
    final pubspecAssetId = AssetId(buildStep.inputId.package, _pubspecFileName);
    final pubspecAsString = await buildStep.readAsString(pubspecAssetId);
    return loadYaml(pubspecAsString) as YamlMap?;
  }

  Future<String> _generateRFileContent(
    BuildStep buildStep,
    YamlMap pubspecYamlMap,
    _GeneratorOptions options,
  ) async {
    final assets = await _getAssetsFromPubspec(
      buildStep,
      pubspecYamlMap,
    );

    final imagesClassGenerator = ImageAssetClassGenerator(assets);
    final imageResourcesClass = await imagesClassGenerator.generate();

    final svgClassGenerator = SvgAssetClassGenerator(assets);
    final svgResourcesClass = await svgClassGenerator.generate();

    final fontClassGenerator = FontClassGenerator(assets);
    final fontResourcesClass = await fontClassGenerator.generate();

    final stringsClassGenerator = StringsClassGenerator(
      localizationData: await _readLocalizationFiles(buildStep, options),
      supportedLocales: options.supportedLocales,
      fallbackLocale: options.fallbackLocale,
    );
    final stringResourcesClasses = await stringsClassGenerator.generate();

    final generatedFileContent = StringBuffer()
      ..writeln(generatedFileHeader)
      ..writeln()
      ..writeln(ignoreCommentForLinter)
      ..writeln()
      ..writeln('import \'package:flutter/material.dart\';')
      ..writeln()
      ..writeln('class R {')
      ..writeln(
        '  static const images = ${imagesClassGenerator.className}();',
      )
      ..writeln(
        '  static const svg = ${svgClassGenerator.className}();',
      )
      ..writeln(
        '  static const fonts = ${fontClassGenerator.className}();',
      )
      ..writeln(
        '  static ${stringsClassGenerator.className} '
        'stringsOf(BuildContext context) => '
        '${stringsClassGenerator.className}.of(context);',
      )
      ..writeln('}')
      ..writeln()
      ..writeln(imageResourcesClass)
      ..writeln()
      ..writeln(svgResourcesClass)
      ..writeln()
      ..writeln(fontResourcesClass)
      ..writeln()
      ..writeln(stringResourcesClasses);

    return generatedFileContent.toString();
  }

  Future<List<AssetId>> _getAssetsFromPubspec(
    BuildStep buildStep,
    YamlMap pubspecYamlMap,
  ) async {
    final globList = _getUniqueAssetsGlobsFromPubspec(pubspecYamlMap);
    final assetsSet = <AssetId>{};

    for (final glob in globList) {
      final assets = await buildStep.findAssets(glob).toList();
      assetsSet.addAll(
        assets.where(
          // remove invisible files: .gitignore, .DS_Store, etc.
          (it) => it.pathSegments.last.fileName.isNotEmpty,
        ),
      );
    }

    return assetsSet.toList();
  }

  Set<Glob> _getUniqueAssetsGlobsFromPubspec(YamlMap pubspecYamlMap) {
    final globList = <Glob>{};
    for (final asset in _getUniqueAssetsPathsFromPubspec(pubspecYamlMap)) {
      if (asset.endsWith('/')) {
        globList.add(Glob('$asset*'));
      } else {
        globList.add(Glob(asset));
      }
    }

    return globList;
  }

  Set<String> _getUniqueAssetsPathsFromPubspec(YamlMap pubspecYamlMap) {
    if (pubspecYamlMap.containsKey('flutter')) {
      final dynamic flutterMap = pubspecYamlMap['flutter'];
      if (flutterMap is YamlMap && flutterMap.containsKey('assets')) {
        final assetsList = flutterMap['assets'] as YamlList;
        return Set.from(assetsList);
      }
    }

    return {};
  }

  Future<Map<String, Map<String, String>>> _readLocalizationFiles(
    BuildStep buildStep,
    _GeneratorOptions options,
  ) async {
    final result = <String, Map<String, String>>{};
    for (final locale in options.supportedLocales) {
      final assetId = AssetId(
        buildStep.inputId.package,
        'assets/strings/$locale.json',
      );
      final fileContentAsString = await buildStep.readAsString(assetId);
      final Map<String, dynamic> decodedJson = jsonDecode(fileContentAsString);
      result[locale] = Map<String, String>.from(decodedJson);
    }
    return result;
  }
}
