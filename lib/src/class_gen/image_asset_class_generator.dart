import 'package:build/build.dart';
import 'package:meta/meta.dart' show protected;

import 'asset_class_generator.dart';

class ImageAssetClassGenerator extends AssetClassGenerator {
  ImageAssetClassGenerator(this._assets);

  final List<AssetId> _assets;

  @override
  String get className => '_ImageResources';

  @override
  @protected
  String get assetFolderName => 'images';

  @override
  @protected
  List<AssetId> get assets => _assets;
}
