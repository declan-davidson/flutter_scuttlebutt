import 'package:flutter/material.dart';
import 'package:scuttlebutt_feed/scuttlebutt_feed.dart';

class NewPostDialog extends StatefulWidget{
  final String identity;
  final String encodedSk;

  const NewPostDialog({Key? key, required this.identity, required this.encodedSk}) : super(key: key);

  @override
  State<NewPostDialog> createState() => _NewPostDialogState();
}

class _NewPostDialogState extends State<NewPostDialog>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post dialog screen"),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Message",
                  border: OutlineInputBorder()
                ),
                onSaved: (String? message) {
                  if(message != null) _message = message;
                }
              ),
              ElevatedButton(
                child: const Text("Post"),
                onPressed: () async {
                  _formKey.currentState?.save();
                  if(_message != null){
                    await FeedService.postMessage(_message, widget.identity, widget.encodedSk);
                    Navigator.pop(context);
                  }
                },
              )
            ],
          ),
        ),
      )
    );
  }
}