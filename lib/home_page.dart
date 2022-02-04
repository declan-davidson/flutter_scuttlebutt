import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sodium/flutter_sodium.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  late SharedPreferences sharedPreferences;
  late TabController _tabController;
  String identity = "Author";
  List<Tab> _tabs = [Tab(child: Text("Messages", style: GoogleFonts.robotoMono())), Tab(child: Text("Private messages", style: GoogleFonts.robotoMono()))]; //Right now these aren't correctly changed, they have to be manuially done. Maybe we need to set different styles in main.dart?
  List<dynamic> messages = [];
  List<dynamic> privateMessages = [];

  @override
  void initState() {
    super.initState();
    checkIdentityExists();
    //sharedPreferences = await SharedPreferences.getInstance();
/* 
    if(!(sharedPreferences.containsKey("identity")) || !(sharedPreferences.containsKey("privateKey"))){
      Sodium.init();
      KeyPair keyPair = Sodium.cryptoSignSeedKeypair((RandomBytes.buffer(32)));
      String identity = base64Encode(keyPair.pk);

      sharedPreferences.setString("identity", "@$identity.ed25519");
      sharedPreferences.setString("privateKey", base64Encode(keyPair.pk));
    }

    String? identity = sharedPreferences.getString("identity");
    this.identity = identity!; */
    _tabController = TabController(vsync: this, length: _tabs.length);
  }

  void checkIdentityExists() async {
    sharedPreferences = await SharedPreferences.getInstance();

    if(!(sharedPreferences.containsKey("identity")) || !(sharedPreferences.containsKey("privateKey"))){
      Sodium.init();
      KeyPair keyPair = Sodium.cryptoSignSeedKeypair((RandomBytes.buffer(32)));
      String identity = base64Encode(keyPair.pk);

      await sharedPreferences.setString("identity", "@$identity.ed25519");
      await sharedPreferences.setString("privateKey", base64Encode(keyPair.pk));
    }

    setState(() {
      identity = sharedPreferences.getString("identity") ?? "ID not found";
    });
  }

  /* void _insertRow() async {
    await widget.db.insert("test", { "content": rng.nextInt(1000) });
    rows = await widget.db.query("test");
    setState(() {
    });
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.menu), onPressed: () => {},),
        title: Text("Some title"),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              children: [
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person_rounded),
                        title: Text(identity),
                        subtitle: Text("x hours ago")
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Text("A message would go here. Something like LALALALALALALALALALA here's some really cool interesting things I want to say!"),
                      ),
                    ],
                  ),
                ),
              ]
            ),
          ),
          const Text("Tab 2"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /* List<TableRow> generateTableRows(){
    List<TableRow> tableRows = [const TableRow(children: [Text("ID"), Text("Content")])];

    rows.forEach((element) {
      List<Text> entries = [];

      element.forEach((key, value) {
        entries.add(Text(value.toString()));
      });

      tableRows.add(TableRow(children: entries));
    });

    return tableRows;
  } */
}

/* Future<Database> openTestDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), "test.db"),
    version: 1,
    onCreate: (db, version) {
      return db.execute("CREATE TABLE test(id INTEGER PRIMARY KEY AUTOINCREMENT, content INTEGER NOT NULL)");
    },
    onConfigure: (db) { db.execute("PRAGMA foreign_keys = ON"); }
  );
} */
