import 'package:flutter/material.dart';
import 'package:verlichting/lights_adjuster.dart';
import 'package:verlichting/programmes_selector.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verlichting',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Verlichting'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentWidgetIndex = 0;

  final List<Widget> _widgets = [
    new ProgrammesSelectorWidget(),
    new LightsAdjusterWidget()
  ];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: _widgets[_currentWidgetIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentWidgetIndex, // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.list),
            title: new Text('Programmes'),
          ),
//          BottomNavigationBarItem(
//            icon: new Icon(Icons.date_range),
//            title: new Text('Vacation mode'),
//          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline),
              title: Text('Lights')
          )
        ],
        onTap: _onTabTapped,
    )
    );
  }

  _onTabTapped(int index) {
    setState(() {
      _currentWidgetIndex = index;
    });
  }

}
