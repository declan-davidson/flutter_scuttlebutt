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
    buttonProps = { "label": Text("Next"), "color": Colors.blue, "onPressed": nextPage };
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
                foregroundColor: Colors.blue,
                shape: StadiumBorder(side: BorderSide(width: 2, color: Colors.blue)),
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
      createTutorialPage("Page 1"),
      createTutorialPage("Page 2"),
      createTutorialPage("Page 3"),
      createTutorialPage("Page 4")
    ];
  }

  Widget createTutorialPage(String content, { bool isLastPage = false}){
    return Center(child: Text(content),);
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

      if(currentPage == 2)
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
    if(currentPage <= 3){
      buttonProps = { "label": Text("Next"), "color": Colors.blue, "onPressed": nextPage };
      setState(() {});
    }
  }
}