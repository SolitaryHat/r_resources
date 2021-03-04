// ignore: import_of_legacy_library_into_null_safe
import 'package:build/build.dart';
import 'package:meta/meta.dart' show protected;

import 'asset_class_generator.dart';

class SvgAssetClassGenerator extends AssetClassGenerator {
  SvgAssetClassGenerator(this._assets);

  final List<AssetId> _assets;

  @override
  String get className => '_SvgResources';

  @override
  @protected
  String get assetFolderName => 'svg';

  @override
  @protected
  List<AssetId> get assets => _assets;
}
