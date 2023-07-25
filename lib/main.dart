import 'package:flutter/material.dart';
import 'widgets/web_view_banner.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Your App'),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: <Widget>[
                Container(
                  height: constraints.maxHeight * 0.25,
                  child: const WebViewBanner(),
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey[300], // Or another widget here
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Your WebViewBanner class here
