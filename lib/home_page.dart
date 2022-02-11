import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_scuttlebutt/new_post_dialog.dart';
import 'package:flutter_scuttlebutt/post_message_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:scuttlebutt_feed/scuttlebutt_feed.dart';
import 'package:time_elapsed/time_elapsed.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  Random rng = Random();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String dummyContent = "Hi! This is ANOTHER REALLY BIG MESSAGE to check if the cards expand properly! They definitely should do! I'll be VERY upset if they don't! >:( Hi! This is a REALLY BIG MESSAGE to check if the cards expand properly! They definitely should do! I'll be VERY upset if they don't! >:(";
  late SharedPreferences sharedPreferences;
  late TabController _tabController;
  late String identity;
  late String encodedSk;

  List<Tab> _tabs = [Tab(child: Text("Messages")), Tab(child: Text("Private messages"))]; //Right now these aren't correctly changed, they have to be manually done. Maybe we need to set different styles in main.dart?
  List<FeedMessage> messages = [];
  String lastMessageBody = "We haven't checked yet!";


  @override
  void initState() {
    super.initState();
    setOptimalDisplayMode();
    checkIdentityExists().then((void x) => retrieveMessages());
    _tabController = TabController(vsync: this, length: _tabs.length);
  }

  void makeTestPost() async {
    try{
      await FeedService.postMessage(dummyContent, identity, encodedSk);
      messages = await FeedService.retrieveMessages(identity: identity);
      
      setState(() {
      });
    }
    on Exception catch(e){
      lastMessageBody = e.toString();
      setState(() {
      });
    }
  }

  void retrieveMessages() async {
    messages = await FeedService.retrieveMessages(identity: identity);
    setState(() {
    });
  }

  String readableTime(int timestamp){
    DateTime timestampDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return TimeElapsed.fromDateTime(timestampDate);
  }

  Future<void> checkIdentityExists() async {
    sharedPreferences = await SharedPreferences.getInstance();

    if(!(sharedPreferences.containsKey("identity")) || !(sharedPreferences.containsKey("encodedSk"))){
      Sodium.init();
      KeyPair keyPair = Sodium.cryptoSignSeedKeypair((RandomBytes.buffer(32)));
      String encodedPk = base64Encode(keyPair.pk);

      await sharedPreferences.setString("identity", "@$encodedPk.ed25519");
      await sharedPreferences.setString("encodedSk", base64Encode(keyPair.sk));
    }

    setState(() {
      identity = sharedPreferences.getString("identity") ?? "";
      encodedSk = sharedPreferences.getString("encodedSk") ?? "";
    });
  }

  //This currently appears to be ignored, at least on my phone
  Future<void> setOptimalDisplayMode() async {
    final List<DisplayMode> supported = await FlutterDisplayMode.supported;
    final DisplayMode active = await FlutterDisplayMode.active;

    final List<DisplayMode> sameResolution = supported.where(
            (DisplayMode m) => m.width == active.width
                && m.height == active.height).toList()..sort(
            (DisplayMode a, DisplayMode b) =>
                b.refreshRate.compareTo(a.refreshRate));

    final DisplayMode mostOptimalMode = sameResolution.isNotEmpty
        ? sameResolution.first
        : active;
    
    await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
  }

  @override
  Widget build(BuildContext context) {
    print("Building homepage");
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
          //MESSAGES TAB
          produceMessageList(),

          //PRIVATE MESSAGES TAB
          const Text("Tab 2"),
        ],
      ),
      bottomSheet: PostMessageSheet(identity: identity, encodedSk: encodedSk, refreshMessageListCallback: retrieveMessages,), /* ElevatedButton(
        child: Text("whatever"),
        onPressed: () => showModalBottomSheet(context: context, builder: (context){ return Text("whatever"); }).then((value) => setState(() {})), //this is how we trigger setState
      ), */
      floatingActionButton: FloatingActionButton(onPressed: () => setState(() {}),)
    );
  }

  Widget produceMessageList(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: ListView.separated(
        itemCount: messages.length,
        itemBuilder: (BuildContext c, int i){
          return Card(
            elevation: 3.5,
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 8)),
                ListTile(
                  leading: Icon(Icons.person_rounded),
                  title: Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 4),
                    child: Text(messages[i].author, overflow: TextOverflow.fade, softWrap: false,),
                  ),
                  subtitle: Text(readableTime(messages[i].timestamp)),
                  contentPadding: EdgeInsets.fromLTRB(16, 0, 24, 0),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(messages[i].content["content"]),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext c, int i) => Padding(padding: EdgeInsets.only(bottom: 8))
      ),
    );
  }
}