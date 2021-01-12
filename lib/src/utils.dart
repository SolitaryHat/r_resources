import 'package:build/build.dart';

extension FlutterResourcesStringExt on String {
  String get fileName {
    return substring(
      lastIndexOf('/') + 1,
      lastIndexOf('.'),
    );
  }

  String toValidPropertyName() {
    final validCharsString = replaceAllMapped(
      RegExp(r'[^_a-zA-Z0-9]+'),
      (match) => '_',
    );
    final lowercased = validCharsString.split(RegExp(r"(?=(?!^)[A-Z])")).fold(
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
    return lowercased;
  }
}

extension FlutterResourcesAssetExt on AssetId {
  String get fileName => pathSegments.last.fileName;
}
