import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  List<Tab> _tabs = [Tab(child: Text("Messages", style: GoogleFonts.robotoMono())), Tab(child: Text("Private messages"))]; //Right now these aren't correctly changed, they have to be manuially done. Maybe we need to set different styles in main.dart?
  List<dynamic> messages = [];
  List<dynamic> privateMessages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
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
                      const ListTile(
                        leading: Icon(Icons.person_rounded),
                        title: Text("Author here"),
                        subtitle: Text("x hours ago")
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Text("A message would go here. Something like LALALALALALALALALALA here's some really cool interesting message!A message would go here. Something like LALALALALALALALALALA here's some really cool interesting message!A message would go here. Something like LALALALALALALALALALA here's some really cool interesting message!A message would go here. Something like LALALALALALALALALALA here's some really cool interesting message!A message would go here. Something like LALALALALALALALALALA here's some really cool interesting message!A message would go here. Something like LALALALALALALALALALA here's some really cool interesting message!A message would go here. Something like LALALALALALALALALALA here's some really cool interesting message!A message would go here. Something like LALALALALALALALALALA here's some really cool interesting message!A message would go here. Something like LALALALALALALALALALA here's some really cool interesting message!A message would go here. Something like LALALALALALALALALALA here's some really cool interesting message!A message would go here. Something like LALALALALALALALALALA here's some really cool interesting message!A message would go here. Something like LALALALALALALALALALA here's some really cool interesting message!"),
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
