import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'r.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
        child: Column(
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
          ],
        ),
      ),
    );
  }
}
