import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:build/build.dart';

import '../utils.dart';
import 'class_generator.dart';

class FontClassGenerator implements ClassGenerator {
  FontClassGenerator(this._assets);

  final List<AssetId> _assets;
  
  @override
  String get className => '_FontResources';

  @override
  FutureOr<String> generate() {
    final classBuffer = StringBuffer()
      ..writeln('class $className {')
      ..writeln('  const $className();');
    final imageAssets = _assets.where(_isTargetAsset).toList();
    if (imageAssets.isNotEmpty) {
      for (final asset in imageAssets) {
        final propertyName = asset.fileName.toValidPropertyName();

        if (propertyName.isNotEmpty) {
          final assetPath = asset.path;
          classBuffer
            ..writeln()
            ..writeln('  final $propertyName = r\'$assetPath\';');
        }
      }
    }

    classBuffer.write('}');
    return classBuffer.toString();
  }

  bool _isTargetAsset(AssetId asset) => 
    asset.pathSegments.any((it) => it == 'fonts');
}