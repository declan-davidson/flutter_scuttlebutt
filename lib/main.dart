import 'dart:io';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scuttlebutt_feed/scuttlebutt_feed.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key){
    openDb();
  }
  final String title;
  late Database db;

  void openDb() async {
    db = await openTestDatabase();
  }

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Random rng = Random();
  List<Map<String, Object?>> rows = [];

  void _insertRow() {
    setState(() async {
      await widget.db.insert("test", { "content": rng.nextInt(1000) });
      rows = await widget.db.query("test");
    });
  }

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
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              children: generateTableRows(),
            )
          )
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _insertRow,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  List<TableRow> generateTableRows(){
    List<TableRow> tableRows = [const TableRow(children: [Text("ID"), Text("Content")])];

    rows.forEach((element) {
      List<Text> entries = [];

      element.forEach((key, value) {
        entries.add(Text(value.toString()));
      });

      tableRows.add(TableRow(children: entries));
    });

    return tableRows;
  }
}
