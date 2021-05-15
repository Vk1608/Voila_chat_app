import 'package:chat_app/helper/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

bool nood = false;

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;

  ConversationScreen({this.chatRoomId});

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageController = new TextEditingController();

  Stream chatMessagesStream;

  Widget chatMessageList() {
    return StreamBuilder(
      stream: chatMessagesStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                      snapshot.data.docs[index].data()["message"],
                      snapshot.data.docs[index].data()["sendBy"] ==
                          Constants.myName,
                      snapshot.data.docs[index].data()["now_time_hour"],
                      snapshot.data.docs[index].data()["now_time_minute"],
                      snapshot.data.docs[index].id,
                      widget.chatRoomId);
                })
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageController.text,
        "sendBy": Constants.myName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "now_time_hour": DateTime.now().hour,
        "now_time_minute": DateTime.now().minute
      };
      databaseMethods.addConversationMessages(widget.chatRoomId, messageMap);
      messageController.text = "";
    }
  }

  @override
  void initState() {
    databaseMethods.getConversationMessages(widget.chatRoomId).then((val) {
      setState(() {
        chatMessagesStream = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('Conv5'),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Color(0xFFF44336),
                  borderRadius: BorderRadius.circular(40)),
              child: Text(
                "${widget.chatRoomId.replaceAll(Constants.myName, "").replaceAll("_", "").substring(0, 1).toUpperCase()}",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                          offset: Offset(4, 4),
                          blurRadius: 7,
                          color: Color(0xFF000000).withOpacity(0.7)),
                    ]),
              ),
            ),
            SizedBox(
              width: 13,
            ),
            Text(
                "${widget.chatRoomId.replaceAll(Constants.myName, "").replaceAll("_", "")} ",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessageList(),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 8),
                        blurRadius: 7,
                        color: Color(0xFFE44336).withOpacity(0.7)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        cursorColor: Color(0xFFE44336),
                        style: TextStyle(color: Colors.black),
                        key: Key('TypeText5'),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          hintText: "Type a message",
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          sendMessage();
                        },
                        child: Container(
                          key: Key('Send5'),
                          height: 40,
                          width: 45,
                          padding: EdgeInsets.all(8),
                          child: Image.asset(
                            "assets/images/send_black.png",
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  final int now_time_hour;
  final int now_time_minute;
  final String Id;

  final String chatId;

  deleteMessage(BuildContext context) {
    Widget Yes = FlatButton(
      child: Text("Delete"),
      onPressed: () {
        FirebaseFirestore.instance
            .collection("ChatRoom")
            .doc(chatId)
            .collection("chats")
            .doc(Id)
            .delete()
            .whenComplete(() {
          print("Deleted ${message}, ${Id}");
        });
        Navigator.of(context).pop();
      },
    );
    Widget No = FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("Cancel"));
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("Are you sure?"),
      content: Text("Do you really want to delete this? Message will be deleted for everyone."),
      actions: [Yes, No],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  MessageTile(this.message, this.isSendByMe, this.now_time_hour,
      this.now_time_minute, this.Id, this.chatId);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
            left: isSendByMe ? 0 : 15, right: isSendByMe ? 15 : 0),
        margin: EdgeInsets.symmetric(vertical: isSendByMe ? 4 : 8),
        width: MediaQuery.of(context).size.width,
        alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
            onLongPress: () {
              deleteMessage(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(2, 5),
                        blurRadius: 7,
                        color: Color(0xFFC12C23).withOpacity(0.5))
                  ],
                  color: isSendByMe ? Color(0xFFE44336) : Color(0xFFFFFFFF),
                  borderRadius: isSendByMe
                      ? BorderRadius.only(
                          topLeft: Radius.circular(23),
                          topRight: Radius.circular(23),
                          bottomLeft: Radius.circular(23))
                      : BorderRadius.only(
                          topLeft: Radius.circular(23),
                          topRight: Radius.circular(23),
                          bottomRight: Radius.circular(23))),
              child: Column(children: [
                Text(
                  message,
                  style: isSendByMe
                      ? TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        )
                      : TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                ),
                Text('${now_time_hour}:$now_time_minute',
                    style: TextStyle(
                        color: isSendByMe
                            ? Color(0xFF000000).withOpacity(0.6)
                            : Color(0xFFE44336).withOpacity(0.6),
                        fontSize: 10),
                    textAlign: isSendByMe ? TextAlign.right : TextAlign.left),
              ]),
            )));
  }
}
