import 'package:flutter/material.dart';
import 'package:flutter_scuttlebutt/tutorial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

void main() {
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isFirstRun(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot){
        if(snapshot.hasData){
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: snapshot.data! ? const Tutorial() : const HomePage(),
/*             initialRoute: /* snapshot.data */ "/tutorial",
            routes: {
              '/': (context) => const HomePage(),
              '/tutorial': (context) => Tutorial()
            }, */
          );
        }
        else{
          return const CircularProgressIndicator();
        }
      }
    );
  }

  Future<SharedPreferences> initialiseSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if(!sharedPreferences.containsKey("firstRun")) sharedPreferences.setBool("firstRun", true);
    if(!sharedPreferences.containsKey("identity")) sharedPreferences.setString("identity", "");
    if(!sharedPreferences.containsKey("encodedSk")) sharedPreferences.setString("encodedSk", "");

    return sharedPreferences;
  }

  Future<bool> isFirstRun() async {
    SharedPreferences sharedPreferences = await initialiseSharedPreferences();
    return sharedPreferences.getBool("firstRun")!;
  }

/*   Future<String> getInitialRoute() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if(!sharedPreferences.containsKey("firstRun")){
      await sharedPreferences.setBool("firstRun", true);
    }

    if(sharedPreferences.getBool("firstRun")!){
      return '/tutorial';
    }
    else{
      return '/';
    }
  } */
}