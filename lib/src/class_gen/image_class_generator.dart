import 'dart:async';

import 'package:flutter_resources/src/class_gen/class_generator.dart';
import 'package:flutter_resources/src/utils.dart';

import 'package:meta/meta.dart' show required;
import 'package:path/path.dart' as path;

class ImageClassGenerator implements ClassGenerator {
  ImageClassGenerator({
    @required List<String> assetPathList,
  })  : assert(assetPathList != null),
        _assetPathList = assetPathList;

  final List<String> _assetPathList;

  @override
  String get className => '_ImageResources';

  @override
  FutureOr<String> generate() {
    final classBuffer = StringBuffer();
    final imageAssets = _assetPathList.where(isImageAsset).toList();
    if (imageAssets.isNotEmpty) {
      classBuffer
        ..writeln('class $className {')
        ..writeln('  const $className();')
        ..writeln();
      for (final assetPath in imageAssets) {
        final propertyName = assetPath.fileName.toValidPropertyName();

        if (propertyName.isNotEmpty) {
          classBuffer
            ..writeln('  /// ![](${path.absolute(assetPath)})') // preview
            ..writeln('  final $propertyName = \'$assetPath\';')
            ..writeln();
        }
      }

      classBuffer.writeln('}');
    }

    return classBuffer.toString();
  }

  bool isImageAsset(String assetPath) {
    final segments = assetPath.split('/');
    return segments.contains('images');
  }
}
