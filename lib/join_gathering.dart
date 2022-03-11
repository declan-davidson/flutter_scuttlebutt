import 'dart:math';

import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:scuttlebutt_feed/scuttlebutt_feed.dart';
import 'dart:convert';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class JoinGathering extends StatefulWidget{
  List<Map<String, String>> identities = [];
  Function setStepCallback;

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
  State<JoinGathering> createState() => _JoinGatheringState();
}

class _JoinGatheringState extends State<JoinGathering>{
  late ThemeData theme;
  late double screenWidth;
  final GlobalKey qrKey = GlobalKey(debugLabel: "QR");
  late QRViewController qrViewController;
  Random random = Random();
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

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(
        title: Text("Join a gathering"),
      ),
      body: QRView(
        cameraFacing: CameraFacing.back,
        key: qrKey,
        onQRViewCreated: _onQrViewCreated,
        overlay: QrScannerOverlayShape(
          overlayColor: Color.fromARGB(166, 54, 54, 54),
          borderColor: Colors.amber
        ),
      ),
      floatingActionButton: Container(
        width: screenWidth - 30,
        child: FloatingActionButton.extended(
          label: Text("Hover over a QR code invite\nto join the gathering", textAlign: TextAlign.center,),
          onPressed: null,
        ),
      ),
    );
  }

  _onQrViewCreated(QRViewController qrViewController) async {
    String correctQr = "A successful test! :)";
    this.qrViewController = qrViewController;
    /* await for(Barcode scannedQrCode in qrViewController.scannedDataStream){
      print("Found code: ${scannedQrCode.code}");
      if(scannedQrCode.code == correctQr) break;
    } */

    qrViewController.scannedDataStream.listen((scannedQrCode) async {
      if(scannedQrCode.code == correctQr){
        await qrViewController.pauseCamera();

        showModalBottomSheet(
          enableDrag: false,
          isDismissible: false,
          isScrollControlled: true,
          constraints: BoxConstraints(maxHeight: double.infinity, maxWidth: screenWidth - 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(25))),
          backgroundColor: Colors.transparent,
          //elevation: 9,
          context: context, 
          builder: (context){
            return Wrap(
              children: [
                Column(
                  children: [
                    Container(
                      width: screenWidth - 30,
                      child: FloatingActionButton.extended(
                        label: Text("Join gathering"),
                        onPressed: () async {
                          await addMessages();
                          widget.setStepCallback(2);
                          Navigator.popUntil(context, ModalRoute.withName("/homePage"));
                        }
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 10)),
                    Container(             
                      width: screenWidth - 30,       
                      child: FloatingActionButton.extended(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.amber,
                        label: Text("Try again"),
                        onPressed: () {
                          qrViewController.resumeCamera();
                          Navigator.pop(context);
                        },
                        shape: StadiumBorder(side: BorderSide(width: 2, color: Colors.amber)),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 10)),
                    Container(
                      width: screenWidth - 30,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.all(Radius.circular(25)))
                      ),
                      padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                      child: Column(
                        children: [
                          Text(
                            "Gathering information:",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headline6,
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 2)),
                          Text(
                            "March on Glasgow city centre to raise awarenesss of the climate emergency",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 10)),
                          Text(
                            "Date:",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headline6,
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 2)),
                          Text(
                            "Today",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          )
                        ],
                      )
                    ),
                    Padding(padding: MediaQuery.of(context).viewInsets + EdgeInsets.only(bottom: 10))
                  ]
                )
              ],
            );
          }
        );
      }
    });

    

   /*  print("Found correct code");
    columnChildren = [
      Expanded(
        flex: 5,
        child: Center(
          child: Text("Successful QR Scan!", style: TextStyle(color: Colors.black, fontSize: 18)),
        )
      ),
      Expanded(
        flex: 5,
        child: Center(
          child: Text("Scan QR invite", style: TextStyle(color: Colors.black, fontSize: 18))
        )
      )
    ];

    setState(() {
      
    }); */

    /* await addMessages();
    widget.setStepCallback(2);
    Navigator.pop(context); */
  }

  Future<void> addMessages() async {
    while(messages.isNotEmpty){
      Map<String, String> identity = widget.identities[random.nextInt(10)];
      String message = messages.removeAt(random.nextInt(messages.length));
      int likes = message == "We're taking the next left down Bank Street #announcements #important" ? 3 : random.nextInt(4);

      await FeedService.postMessage(message, identity["identity"]!, identity["encodedSk"]!, likes: likes);
    }
  }
}