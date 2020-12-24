extension FlutterResourcesStringExt on String {
  String get fileName {
    return substring(
      lastIndexOf('/') + 1,
      lastIndexOf('.'),
    );
  }

  String toValidPropertyName() {
    return replaceAllMapped(
      RegExp(r'[^_a-zA-Z0-9]+'),
      (match) => '_',
    );
  }
}