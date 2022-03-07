import 'dart:math';

import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:scuttlebutt_feed/scuttlebutt_feed.dart';
import 'dart:convert';

class JoinGathering extends StatelessWidget{
  Random random = Random();
  Function setStepCallback;
  List<Map<String, String>> identities = [];
  List<String> messages = [
    "Good luck everyone!",
    "Good luck everyone!",
    "Good luck everyone!",
    "Good luck everyone!",
    "Stay safe guys",
    "Stay safe guys",
    "Stay safe guys",
    "Emergency vehicles approaching from behind #important #watchout",
    "Who's here from XR? #xr",
    "We're taking the next left down Bank Street #announcements #important",
    "Wave your posters high!",
    "Wave your posters high!",
    "Wave your posters high!",
    "Let them hear you!",
    "Let them hear you!",
    "Let them hear you!",
    "Let them hear you!",
    "What do we want? WHEN DO WE WANT IT?! #whatdowewant",
    "What do we want? WHEN DO WE WANT IT?! #whatdowewant",
    "What do we want? WHEN DO WE WANT IT?! #whatdowewant",
    "What do we want? WHEN DO WE WANT IT?! #whatdowewant",
    "We say NO to what's happening! #wesayno",
    "We say NO to what's happening! #wesayno",
    "We say NO to what's happening! #wesayno",
    "Power to the people!",
    "Power to the people!",
    "Power to the people!",
    "Power to the people!",
  ];

  JoinGathering({Key? key, required this.setStepCallback}) : super(key: key){
    for(int i = 0; i < 10; i++){
      KeyPair keyPair = Sodium.cryptoSignSeedKeypair((RandomBytes.buffer(32)));
      String encodedPk = base64Encode(keyPair.pk);
      String identity = "@$encodedPk.ed25519";
      String encodedSk = base64Encode(keyPair.sk);
      
      identities.add({"identity": identity, "encodedSk": encodedSk});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Join a gathering"),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("Join gathering"),
          onPressed: () async {
            await addMessages();
            setStepCallback(2);
            Navigator.pop(context);
          }
        ),
      ),
    );
  }

  Future<void> addMessages() async {
    while(messages.isNotEmpty){
      Map<String, String> identity = identities[random.nextInt(10)];
      String message = messages.removeAt(random.nextInt(messages.length));
      int likes = message == "We're taking the next left down Bank Street #announcements #important" ? 3 : random.nextInt(4);

      await FeedService.postMessage(message, identity["identity"]!, identity["encodedSk"]!, likes: likes);
    }
  }
}