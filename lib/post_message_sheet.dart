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
    double screenWidth = MediaQuery.of(context).size.width;

    return  Container(
      width: screenWidth - 30,
      padding: EdgeInsets.only(left: 2),
      child: FloatingActionButton.extended(
        label: Text("New message"),
        onPressed: () => showModalBottomSheet(
          constraints: BoxConstraints(maxHeight: double.infinity, maxWidth: screenWidth - 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(25))),
          backgroundColor: Colors.transparent,
          //elevation: 9,
          context: context, 
          builder: (context){
            return Form(
              key: _formKey,
              child: Wrap(
                children: [
                  Column(
                    children: [
                      Container(
                        width: screenWidth - 30,
                        child: FloatingActionButton.extended(
                          label: Text("Post message"),
                          onPressed: () async {
                            _formKey.currentState?.save();
                            if(_message != null){
                              await FeedService.postMessage(_message, widget.identity, widget.encodedSk);
                              widget.refreshMessageListCallback();
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      /* ElevatedButton(
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
                      ), */
                      Padding(padding: EdgeInsets.only(bottom: 10)),
                      Container(
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.all(Radius.circular(25)))
                        ),
                        padding: const EdgeInsets.fromLTRB(25, 0, 15, 5),
                        child: TextFormField(
                          maxLines: 6,
                          textCapitalization: TextCapitalization.sentences,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: "Message",
                            border: InputBorder.none
                          ),
                          onSaved: (String? message) {
                            if(message != null) _message = message;
                          },
                        ),
                      ),
                      Padding(padding: MediaQuery.of(context).viewInsets + EdgeInsets.only(bottom: 15))
                    ]
                  )
                ],
              )
            );
          }
        ),
      )
    );
  }

  /* @override
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
  } */
}