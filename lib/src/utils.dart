import 'package:build/build.dart';

/// package internal String extensions
extension FlutterResourcesStringExt on String {
  /// gets filename from path
  String get fileName {
    return substring(
      lastIndexOf('/') + 1,
      lastIndexOf('.'),
    );
  }

  /// transforms string to valid dart property name
  String toValidPropertyName() {
    final validCharsString = replaceAllMapped(
      RegExp(r'[^_a-zA-Z0-9]+'),
      (match) => '_',
    );
    final lowerCased = validCharsString.split(RegExp(r"(?=(?!^)[A-Z])")).fold(
      '',
      (previousValue, element) {
        var result = previousValue as String;
        if (result.isNotEmpty && !result.endsWith('_')) {
          result += '_';
        }
        result += element.toLowerCase();
        return result;
      },
    );
    return lowerCased;
  }
}

/// package internal AssetId extensions
extension FlutterResourcesAssetExt on AssetId {
  /// gets filename from AssetId
  String get fileName => pathSegments.last.fileName;
}
