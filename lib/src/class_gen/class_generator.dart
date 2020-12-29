import 'dart:async';

abstract class ClassGenerator {
  String get className;
  FutureOr<String> generate();
}