import 'package:build/build.dart';
import 'package:meta/meta.dart' show protected;

import 'asset_class_generator.dart';

/// AssetClassGenerator to create references to plain images
class ImageAssetClassGenerator extends AssetClassGenerator {

  /// Creates ImageAssetClassGenerator with specified list of assets
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
