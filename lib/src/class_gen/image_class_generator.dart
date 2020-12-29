import 'dart:async';

import 'package:build/build.dart';
import 'package:flutter_resources/src/class_gen/class_generator.dart';
import 'package:flutter_resources/src/utils.dart';

import 'package:path/path.dart' show absolute;

class ImageClassGenerator implements ClassGenerator {
  ImageClassGenerator(this._assets);

  final List<AssetId> _assets;

  @override
  String get className => '_ImageResources';

  @override
  FutureOr<String> generate() {
    final classBuffer = StringBuffer()
      ..writeln('class $className {')
      ..writeln('  const $className();');
    final imageAssets = _assets.where(_isImageAsset).toList();
    if (imageAssets.isNotEmpty) {
      for (final asset in imageAssets) {
        final propertyName = asset.fileName.toValidPropertyName();

        if (propertyName.isNotEmpty) {
          final assetPath = asset.path;
          classBuffer
            ..writeln()
            ..writeln('  /// ![](${absolute(assetPath)})')
            ..writeln('  final $propertyName = r\'$assetPath\';');
        }
      }
    }

    classBuffer.write('}');
    return classBuffer.toString();
  }

  bool _isImageAsset(AssetId asset) {
    return asset.pathSegments.any((it) => it == 'images');
  }
}
