import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';

import 'r.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      supportedLocales: RStringsDelegate.supportedLocales,
      localizationsDelegates: [
        RStringsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(title: 'Flutter Demo Home Page'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text('Image res:'),
            Image.asset(
              R.images.ic_individual_schools,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 8),
            Text('SVG res:'),
            SvgPicture.asset(
              R.svg.filter,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              color: Colors.amber[500],
            ),
            SizedBox(height: 8),
            Text('Font res:'),
            SizedBox(height: 8),
            Text(
              'Lorem Ipsum',
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    fontFamily: R.fonts.noto_sans_bold,
                  ),
            ),
            SizedBox(height: 8),
            Text('String res:'),
            SizedBox(height: 8),
            Text(R.stringsOf(context).label_lorem_ipsum),
            Text(R.stringsOf(context).label_color),
            SizedBox(height: 8),
            Text('String res formatted:'),
            Text(
              R.stringsOf(context).format_example(
                    object: 12345,
                    other: 'OTHER',
                  ),
            ),
            SizedBox(height: 8),
            Text('String res with special characters:'),
            Text(
              R.stringsOf(context).label_with_newline,
            ),
            SizedBox(height: 8),
            Text('Currnt localization locale:'),
            Text(
              R.stringsOf(context).locale.toString(),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
