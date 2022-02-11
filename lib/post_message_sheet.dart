import 'package:flutter/material.dart';
import 'package:scuttlebutt_feed/scuttlebutt_feed.dart';

class PostMessageSheet extends StatefulWidget{
  final String identity;
  final String encodedSk;
  final VoidCallback refreshMessageListCallback;

  const PostMessageSheet({Key? key, required this.identity, required this.encodedSk, required this.refreshMessageListCallback}) : super(key: key);

  @override
  State<PostMessageSheet> createState() => _PostMessageSheetState();
}

class _PostMessageSheetState extends State<PostMessageSheet>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 9,
            color: Colors.grey
          )
        ]
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
          shape: const RoundedRectangleBorder()
        ),
        child: const Text("New message"),
        onPressed: () => showModalBottomSheet(
          elevation: 9,
          context: context, 
          builder: (context){
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                      shape: const RoundedRectangleBorder()
                    ),
                    child: const Text("Post message"),
                    onPressed: () async {
                      _formKey.currentState?.save();
                      if(_message != null){
                        await FeedService.postMessage(_message, widget.identity, widget.encodedSk);
                        widget.refreshMessageListCallback();
                        Navigator.pop(context);
                      }
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                    child: TextFormField(
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(labelText: "Message"),
                      onSaved: (String? message) {
                        if(message != null) _message = message;
                      },
                    ),
                  ),
                  const ListTile(
                    title: Text("Item 2"),
                  )
                ],
              )
            );
          }),
      ),
    );
  }
}