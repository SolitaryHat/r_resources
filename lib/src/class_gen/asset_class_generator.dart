import 'dart:async';

import 'package:build/build.dart';
import 'package:meta/meta.dart' show protected;
import 'package:path/path.dart';

import '../utils.dart';
import 'class_generator.dart';

/// abstract ClassGenerator that is used to generate reference class
/// by simply converting assets in specified folder to references
abstract class AssetClassGenerator implements ClassGenerator {
  /// Describes folder that used to filter all project assets
  @protected
  String get assetFolderName;

  /// All project assets
  @protected
  List<AssetId> get assets;

  @override
  FutureOr<String> generate() {
    final classBuffer = StringBuffer()
      ..writeln('class $className {')
      ..writeln('  const $className();');
    final imageAssets = assets.where(_isTargetAsset).toList();
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

  bool _isTargetAsset(AssetId asset) =>
      asset.pathSegments.any((it) => it == assetFolderName);
}
