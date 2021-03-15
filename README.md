# r_resources
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://pub.dev/packages/effective_dart)
![PR checks](https://github.com/SolitaryHat/r_resources/workflows/PR%20checks/badge.svg)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This package is made for R-file code generation using `build_runner`. 

R file contains static access to application asset names and inherited access (via `BuildContext`) to localized String resources.

With this approach you will not be able to make a typo in any resource name.

## How to use

To use the resources code generation add dev dependency in your `pubspec.yaml`:

```yaml
dev_dependencies:
  build_runner: <build_runner version here>
  r_resources: ^0.0.5
```

To generate R-file, run build_runner: `flutter pub run build_runner build`. `r.dart` file will be created in `lib` filder

## Plain images and SVG 

In order to generate R-names for image assets, you need to follow these steps:

1) Create `assets` folder in project root folder (`your_app/assets`)
2) Create `images` folder for plain image files (such as .png, .jpg, etc.). And/Or create `svg` folder for .svg files.
3) Add image assets to these folders.
4) Add `assets` to `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/svg/
```
5) Run code generation

Note: to add plain images for different scale factors you may add scaled folders inside `images` folder.  

```
your_app:
  assets:
    images:
      2.0x:
        img.png
      3.0x:
        img.png
      img.png
```

After `r.dart` is generated, you can reference assets like follows:

```dart
Image.asset(R.images.ic_individual_schools);
SvgPicture.asset(R.svg.ic_filter);
```

## Configuration file

`r_resources` provides some configuration to code gen.

Add the `r_options.yaml` config file to project root folder. Example:

```yaml
path: 'lib/codegen'

generate_strings: true

supported_locales:
  - en_US
  - en_GB
  - ru

fallback_locale: en_US
```

Parameters:

`path` - parameter describing where `r.dart` would be saved. Path should always start with `lib` folder. Equals `lib` by default.

`generate_strings` - parameter that turns on and off string resources generation. Equals `false` by default, since you may use other localized strings gen packages. 

`supported_locales` - parameter describing which locales will be supported by your app. Equals `en` by default. It is only makes sence to add this parameter when `generate_strings` is `true` otherwise it will be ignored.

`fallback_locale` - parameter describing which locale translations will be used in case of missing translations. Equals `en` by default. It is only makes sence to add this parameter when `generate_strings` is `true` otherwise it will be ignored.

## Strings

`r_resources` provides a simple way to generate string translations to your app. 

This generation is turned off dy default.

### How to use Strings gen

To start generating localized strings resources you should set `generate_strings` parameter to `true` in configuration file.

Also you may need to configure `supported_locales` and `fallback_locale` parameters.

All locale naming used by codegen is using the following format: `<language_code>_<country_code>`. `country_code` may be ommited to use generic language code for all nested countries. Examples: `en_GB`, `ru`, `en`. Note that `en_GB` is not the same as `en`. 

After you configured `generate_strings`, `supported_locales` and `fallback_locale` parameters, you should add translation files to `your_app/assets/strings`.

In case you specified `r_options.yaml` like this:
```yaml
generate_strings: true

supported_locales:
  - en_US
  - en_GB
  - ru

fallback_locale: en_US
```
then you should add `en_US.json`, `en_GB.json` and `en_US.json` files. And you need to make sure that `en_US.json` file contains all possible translations, since it will be used as a fallback.

Translations files are single json-s. Field names in different tranlstion files should match.

`en_US.json` (fallback locale):
```json
{
    "label_lorem_ipsum": "Lorem ipsum",
    "label_color": "Color",
    "format_example": "Your object is ${object} and other is ${other}",
    "label_with_newline": "HELLO!\nI'm new line symbol (\\n)"
}
```

`ru.json`:
```json
{
    "label_color": "Цвет",
    "format_example": "Ты передал object = ${object}"
}
```

With these files have been used to generate R, you can access localized values in code as follows:

```dart
Text(R.stringsOf(context).label_lorem_ipsum);
Text(R.stringsOf(context).label_color);
```

After successfull code generation `r.dart` will have 2 new classes: 
1) `_Strings` which instance can be accesed by `R.stringsOf(context)` and used as localized values container
2) `RStringsDelegate` - the `LocalizationsDelegate` for type `_Strings`

You should use `RStringsDelegate` to configure localizations of your app widget:

```dart
return MaterialApp(
  ...,
  supportedLocales: RStringsDelegate.supportedLocales,
  localizationsDelegates: [
    RStringsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  ...,
 );
```

### Formatting
This package is also supports localized formatting:

`en_US.json` (fallback locale):
```json
{
    "format_example": "Your object is ${object} and other is ${other}"
}
```

`ru.json`:
```json
{
    "format_example": "Ты передал object = ${object}"
}
```

It looks like string interpolation in json files. After generation you will have the following function instead of getter in `_Strings` class:

```dart
String format_example({
  required Object object,
  required Object other,
});
```

It can be used in code as follows:

```dart
Text(
  R.stringsOf(context).format_example(
    object: 12345,
    other: 'OTHER',
  ),
),
```

## Planned features

☑ Plain images
☑ SVG
☑ String resources
☐ Colors
☐ Text styles
☐ Themes

## License

Licensed under the [MIT License](LICENSE).
