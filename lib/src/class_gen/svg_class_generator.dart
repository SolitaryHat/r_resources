import 'dart:async';

import 'package:build/build.dart';
import 'package:r_resources/src/class_gen/class_generator.dart';
import 'package:r_resources/src/utils.dart';

import 'package:path/path.dart' show absolute;

class SvgClassGenerator implements ClassGenerator {
  SvgClassGenerator(this._assets);

  final List<AssetId> _assets;

  @override
  String get className => '_SvgResources';

  @override
  FutureOr<String> generate() {
    final classBuffer = StringBuffer()
      ..writeln('class $className {')
      ..writeln('  const $className();');
    final imageAssets = _assets.where(_isValidAsset).toList();
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

  bool _isValidAsset(AssetId asset) {
    return asset.pathSegments.any((it) => it == 'svg');
  }
}
