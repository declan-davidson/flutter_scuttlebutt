import 'package:flutter/material.dart';
import 'package:flutter_scuttlebutt/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'dart:convert';

class Tutorial extends StatefulWidget{
  const Tutorial({Key? key}) : super(key: key);

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial>{
  late SharedPreferences sharedPreferences;
  late Map<String, dynamic> buttonProps;
  final controller = PageController();

  @override
  void initState() {
    buttonProps = { "label": Text("Next"), "color": Colors.amber, "onPressed": nextPage };
    getSharedPreferencesInstance();
    super.initState();
  }

  void getSharedPreferencesInstance() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        physics: NeverScrollableScrollPhysics(),
        children: createTutorialPages()
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                label: buttonProps["label"],
                backgroundColor: buttonProps["color"],
                onPressed: buttonProps["onPressed"],
              ),
              const Padding(padding: EdgeInsets.only(top: 15)),
              FloatingActionButton.extended(
                label: Text("Back"),
                onPressed: previousPage,
                backgroundColor: Colors.white,
                foregroundColor: Colors.amber,
                shape: StadiumBorder(side: BorderSide(width: 2, color: Colors.amber)),
              )
            ]
          )
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  List<Widget> createTutorialPages(){
    return [
      createTutorialPage("The strength of public expression is powerful, and is amplified by unity. \n\nGatherings, marches and protests have brought down oppresive governments, improved racial equality and harkened the dawn of modern worker's rights."),
      createTutorialPage("The most effective change comes when many act as one. Communication is key, and it's importance makes it a valuable target for opponents.\n\nMost apps use the internet to work, and so they're all vulnerable to disruption and blocking."),
      createTutorialPage("Gather is different. It's decentralised, so all your messages stay in the protest and not in the world wide web. Automatic encryption means nobody can intercept what you send and receive.\n\nAll you need to do is join a gathering, and you're able to communicate with security and safety in mind."),
      createTutorialPage("Everyone's messages are placed in a single, shared channel. Sending a message adds it to the top of the feed.\n\nYou can use hashtags to copy messages into different channels, to make discussing specific things simpler.\n\nLiking messages gives them greater prominence, making important messages easier for everyone to read."),
      createTutorialPage("Your identity on Gather is transient.\n\nYou don't need to provide any personal information, and you can change it at any time.")
    ];
  }

  Widget createTutorialPage(String content, { bool isLastPage = false}){
    return Center(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          content,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.black),
        ),
      )
    );
    /* return Scaffold(
      body: Container(
        child: Center(
          child: Text(content),
        ),
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          label: Text("Continue"),
          backgroundColor: Colors.blue,
          onPressed: null,
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    ); */
  }

  void nextPage(){
    double currentPage = controller.page!;

    if(currentPage % 1 == 0){
      controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.ease);

      if(currentPage == 3)
        buttonProps = { "label": Text("Create identity"), "color": Colors.green, "onPressed": createIdentity };
        setState(() {});
    }
  }

  void createIdentity(){
    double currentPage = controller.page!;

    if(currentPage % 1 == 0){
      Sodium.init();
      KeyPair keyPair = Sodium.cryptoSignSeedKeypair((RandomBytes.buffer(32)));
      String encodedPk = base64Encode(keyPair.pk);
      sharedPreferences.setString("identity", "@$encodedPk.ed25519");
      sharedPreferences.setString("encodedSk", base64Encode(keyPair.sk));

      sharedPreferences.setBool("firstRun", false);
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: ((context) => const HomePage())),
        (Route<dynamic> route) => false
      );
    }
  }

  void previousPage(){
    double currentPage = controller.page!;

    if(currentPage >= 1) controller.previousPage(duration: Duration(milliseconds: 500), curve: Curves.ease);
    if(currentPage <= 4){
      buttonProps = { "label": Text("Next"), "color": Colors.amber, "onPressed": nextPage };
      setState(() {});
    }
  }
}