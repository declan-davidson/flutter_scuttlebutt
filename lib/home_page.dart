import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scuttlebutt/new_post_dialog.dart';
import 'package:flutter_scuttlebutt/post_message_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:scuttlebutt_feed/scuttlebutt_feed.dart';
import 'package:time_elapsed/time_elapsed.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
//import 'package:dart_muxrpc/dart_muxrpc.dart';
import 'package:flutter_muxrpc/flutter_muxrpc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late SharedPreferences sharedPreferences;
  late TabController _tabController;
  late String identity;
  late String encodedSk;

  List<Tab> _tabs = [];
  Map<String, List<FeedMessage>> filteredMessages = {};


  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((duration) async {
      await setOptimalDisplayMode();
      await getIdentity();
      await retrieveMessages();
    });
    super.initState();
  }

  Future<void> retrieveMessages() async {
    RegExp hashtagRegex = RegExp(r"(?=\s*)#(?:[^\s#])+");
    _tabs = [const Tab(child: Text("All messages")), const Tab(child: Text("Most liked"))];
    filteredMessages = { "All messages": [], "Most liked": [] };
    List<FeedMessage> messages = await FeedService.retrieveMessages(identity: identity, hops: 2);

    for(FeedMessage message in messages){
      Iterable<RegExpMatch> channels = hashtagRegex.allMatches(message.content["content"]);

      for(RegExpMatch channel in channels){
        String channelString = channel.group(0)!;

        if(!(filteredMessages.containsKey(channelString))){
          filteredMessages[channelString] = [];
          _tabs.add(Tab(child: Text(channelString)));
        }

        filteredMessages[channelString]!.add(message);
      }

      if(message.likes > 0) filteredMessages["Most liked"]!.add(message);
      filteredMessages["All messages"]!.add(message);
    }

    filteredMessages["Most liked"]!.sort((b, a) => a.likes.compareTo(b.likes));

    _tabController = TabController(vsync: this, length: _tabs.length);

    setState(() {
    });
  }

  String readableTime(int timestamp){
    DateTime timestampDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return TimeElapsed.fromDateTime(timestampDate);
  }

  Future<void> getIdentity() async {
    sharedPreferences = await SharedPreferences.getInstance();

    identity = sharedPreferences.getString("identity")!;
    encodedSk = sharedPreferences.getString("encodedSk")!;
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
    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.menu), onPressed: () => _scaffoldKey.currentState!.openDrawer()),
        title: Text("Some title"),
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          tabs: _tabs,
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              color: Colors.blue,
              child: SafeArea(
                child: Column(
                  children: [
                    ListTile(
                      title: Text("Current profile", style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Color.fromARGB(255, 218, 218, 218))),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                      title: Text(identity, style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white)),
                      leading: Icon(Icons.person_rounded),
                    )
                  ]
                )
              ),
            )
          ],
        )
      ),
      body: TabBarView(
        controller: _tabController,
        children: produceMessageLists(),
      ),
      floatingActionButton: PostMessageSheet(identity: identity, encodedSk: encodedSk, refreshMessageListCallback: retrieveMessages,),
      //bottomSheet: PostMessageSheet(identity: identity, encodedSk: encodedSk, refreshMessageListCallback: retrieveMessages,),
      /* floatingActionButton: FloatingActionButton(
        onPressed: attemptConnection,
      ), */
    );
  }

  void attemptConnection() async {
    RpcClient client = RpcClient();
    client.start();
    await Future.delayed(const Duration(seconds: 2));
    client.createHistoryStream(id: "someId");
    await Future.delayed(const Duration(seconds: 10));
    client.finish();
    retrieveMessages();
  }

  List<Widget> produceMessageLists(){
    List<Widget> messageLists = [];

    filteredMessages.forEach((channel, messages) {
      messageLists.add(produceMessageList(messages));
    });

    return messageLists;
  }

  Widget produceMessageList(List<FeedMessage> messages){
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: ListView.separated(
        itemCount: messages.length,
        itemBuilder: (BuildContext c, int i){
          List<Widget> columnChildren = [
            Card(
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
                    alignment: Alignment(-1, 0),
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(messages[i].content["content"], textAlign: TextAlign.left,),
                  ),
                  ButtonBar(
                    buttonPadding: EdgeInsets.zero,
                    children: [
                      Text(messages[i].likes.toString()),
                      IconButton(
                        onPressed: () async {
                          await FeedService.likeMessage(messages[i].id);
                          retrieveMessages();
                        },
                        icon: Icon(Icons.thumb_up_alt_rounded, color: Colors.grey,),
                        iconSize: 20,
                      ),
                    ],
                  )
                ],
              ),
            )
          ];

          if(i == 0){
            columnChildren.insert(0, Padding(padding: EdgeInsets.only(top: 10)));
          }
          else if(i == messages.length -1){
            columnChildren.add(Padding(padding: EdgeInsets.only(bottom: 72)));
          }

          return Column(
            children: columnChildren
          );
        },
        separatorBuilder: (BuildContext c, int i) => Padding(padding: EdgeInsets.only(bottom: 8))
      ),
    );
  }
}