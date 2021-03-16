import 'dart:async';

/// Interface for any class generator
abstract class ClassGenerator {

  /// className is used while generating a getter in R class
  String get className;

  /// generate is used to create resource reference class
  FutureOr<String> generate();
}
