import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_chat_fluttter/const/const.dart';
import 'package:real_chat_fluttter/model/chat_info.dart';
import 'package:real_chat_fluttter/model/chat_message.dart';
import 'package:real_chat_fluttter/state/state_manager.dart';
import 'package:real_chat_fluttter/utils/utils.dart';
import 'package:real_chat_fluttter/widgets/bubble.dart';

class ChatScreen extends ConsumerWidget {
  ChatScreen({this.app, this.user});

  FirebaseApp app;
  User user;

  DatabaseReference offsetRef, chatRef;
  FirebaseDatabase database;

  TextEditingController _textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    var friendUser = watch(chatUser).state;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff656565),
        centerTitle: true,
        title: Text("${friendUser.firstName} ${friendUser.lastName}"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                flex: 6,
                child: friendUser.uid != null
                    ? FirebaseAnimatedList(
                        controller: _scrollController,
                        sort: (DataSnapshot a, DataSnapshot b) =>
                            b.key.compareTo(a.key),
                        reverse: true,
                        query: loadChatList(context, app),
                        itemBuilder: (BuildContext context,
                            DataSnapshot snapshot,
                            Animation<double> animation,
                            int index) {
                          var chatContent = ChatMessage.fromJson(
                              json.decode(json.encode(snapshot.value)));

                          return SizeTransition(
                            sizeFactor: animation,
                            child: chatContent.picture
                                ? chatContent.senderId == user.uid
                                    ? bubleImageFromUser(chatContent)
                                    : bubleImageFromFriend(chatContent)
                                : chatContent.senderId == user.uid
                                    ? bubleTextFromUser(chatContent)
                                    : bubleTextFromFriend(chatContent),
                          );
                        },
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        expands: false,
                        minLines: null,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Enter your message',
                          //border: InputBorder.none,
                        ),
                        controller: _textEditingController,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 0),
                      child: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          offsetRef.once().then((DataSnapshot snapshot) {
                            var offset = snapshot.value as int;
                            var estimatedServerTimeInMs =
                                DateTime.now().millisecondsSinceEpoch + offset;

                            submitChat(context, estimatedServerTimeInMs);
                          });
                          //Auto scroll chat layout to end
                          autoScroll(_scrollController);
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  loadChatList(BuildContext context, FirebaseApp app) {
    database = FirebaseDatabase(app: app);
    offsetRef = database.reference().child('.info/serverTimeOffset');
    chatRef = database
        .reference()
        .child(CHAT_REF)
        .child(getRoomId(user.uid, context.read(chatUser).state.uid))
        .child(DETAIL_REF);

    return chatRef;
  }

  void submitChat(BuildContext context, int estimatedServerTimeInMs) {
    ChatMessage chatMessage = ChatMessage();
    chatMessage.name = createName(context.read(userLogged).state);
    chatMessage.content = _textEditingController.text;
    chatMessage.timeStamp = estimatedServerTimeInMs;
    chatMessage.senderId = user.uid;

    //Image and Text

    chatMessage.picture = false;
    submitChatToFirebase(context, chatMessage, estimatedServerTimeInMs);
  }

  void submitChatToFirebase(BuildContext context, ChatMessage chatMessage,
      int estimatedServerTimeInMs) {
    chatRef.once().then((DataSnapshot snapshot) {
      if (snapshot != null) // if user already create chat before
        /*   appendChat(context, chatMessage, estimatedServerTimeInMs);
      else*/
        createChat(context, chatMessage, estimatedServerTimeInMs);
    });
  }

  void createChat(BuildContext context, ChatMessage chatMessage,
      int estimatedServerTimeInMs) {
    //Create chat info
    ChatInfo chatInfo = ChatInfo(
        createId: user.uid,
        friendName: createName(context.read(chatUser).state),
        friendId: context.read(chatUser).state.uid,
        createName: createName(context.read(userLogged).state),
        lastMessage: chatMessage.picture ? '<image>' : chatMessage.content,
      lastUpdate: DateTime.now().millisecondsSinceEpoch,
      createDate: DateTime.now().millisecondsSinceEpoch
    );

    //Add on firebase

    database
        .reference()
        .child(CHATLIST_REF)
        .child(user.uid)
        .child(context.read(chatUser).state.uid)
        .set(<String, dynamic>{
          'lastUpdate':chatInfo.lastUpdate,
      'lastMessage':chatInfo.lastMessage,
      'createId':chatInfo.createId,
      'friendId':chatInfo.friendId,
      'createName':chatInfo.createName,
      'friendName':chatInfo.friendName,
      'createDate':chatInfo.createDate,

    }).then((value) {
      //after success, copy to friend chat list
      database
          .reference()
          .child(CHATLIST_REF)
          .child(context.read(chatUser).state.uid)
      .child(user.uid)
          .set(<String, dynamic>{
        'lastUpdate':chatInfo.lastUpdate,
        'lastMessage':chatInfo.lastMessage,
        'createId':chatInfo.createId,
        'friendId':chatInfo.friendId,
        'createName':chatInfo.createName,
        'friendName':chatInfo.friendName,
        'createDate':chatInfo.createDate,

      }).then((value) {
        //After success, add on Chat reference
        chatRef.push().set(<String, dynamic>{
          'uid': chatMessage.uid,
          'name': chatMessage.name,
          'content': chatMessage.content,
          'pictureLink': chatMessage.pictureLink,
          'picture': chatMessage.picture,
          'timeStamp': chatMessage.timeStamp,
          'senderId': chatMessage.senderId,
        }).then((value) {
          //Clear text content
          _textEditingController.text = '';

          //Auto scroll
          autoScrollRevers(_scrollController);
        }).catchError(
            (e) => showOnlySnackBar(context, 'Error submit Chat Ref'));
      }).catchError((e) => showOnlySnackBar(
              context, "Error can not submit Friend Chat List"));
    }).catchError((e) =>
            showOnlySnackBar(context, "Error can not submit to Chat List"));
  }

/*void appendChat(BuildContext context, ChatMessage chatMessage,
      int estimatedServerTimeInMs) {
    var update_data = Map<String, dynamic>();
    update_data['lastUpdate'] = estimatedServerTimeInMs;
    if (chatMessage.picture)
      update_data['update'] = '<Image>';
    else
      update_data['lastMessage'] = chatMessage.content;

    //Update
    database
        .reference()
        .child(CHATLIST_REF)
        .child(user.uid) //you
        .child(context.read(chatUser).state.uid) //friend
        .update(update_data)
        .then((value) {
      //Add to Chat Ref

      chatRef.push().set(<String, dynamic>{
        'uid': chatMessage.uid,
        'name': chatMessage.name,
        'content': chatMessage.content,
        'pictureLink': chatMessage.pictureLink,
        'picture': chatMessage.picture,
        'timeStamp': chatMessage.timeStamp,
        'senderId': chatMessage.senderId,
      }).then((value) {
        //Clear text content
        _textEditingController.text = '';

        //Auto scroll
        autoScrollRevers(_scrollController);
      }).catchError((e) => showOnlySnackBar(context, 'Error submit Chat Ref'));
    }).catchError(
            (e) => showOnlySnackBar(context, 'Cannot update Friend chat list'));
  }*/
}
