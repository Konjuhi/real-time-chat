import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:real_chat_fluttter/model/chat_message.dart';
import 'package:real_chat_fluttter/utils/time_ago.dart';

Widget bubleTextFromUser(ChatMessage chatContent) {
  return Column(
    children: [
      TimeAgo.isSameDay(chatContent.timeStamp)
          ? Container()
          : Text(
              '${TimeAgo.timeAgoSinceDate(chatContent.timeStamp)},',
              style:
                  TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
            ),
      Bubble(
        margin: BubbleEdges.only(top: 10.0),
        alignment: Alignment.topRight,
        nip: BubbleNip.rightBottom,
        color: Colors.black54,
        child: Text(
          '${chatContent.content}',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );
}

Widget bubleImageFromUser(ChatMessage chatContent) {
  return Column(
    children: [
      TimeAgo.isSameDay(chatContent.timeStamp)
          ? Container()
          : Text(
              '${TimeAgo.timeAgoSinceDate(chatContent.timeStamp)},',
              style:
                  TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
            ),
      Bubble(
          margin: BubbleEdges.only(top: 10.0),
          alignment: Alignment.topRight,
          nip: BubbleNip.rightBottom,
          color: Colors.black54,
          child: Column(
            children: [
              Image.network(chatContent.pictureLink),
              Text(
                '${chatContent.content}',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.right,
              ),
            ],
          )),
    ],
  );
}

Widget bubleTextFromFriend(ChatMessage chatContent) {
  return Column(
    children: [
      TimeAgo.isSameDay(chatContent.timeStamp)
          ? Container()
          : Text(
              '${TimeAgo.timeAgoSinceDate(chatContent.timeStamp)},',
              style:
                  TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
            ),
      Bubble(
        margin: BubbleEdges.only(top: 10.0),
        alignment: Alignment.topLeft,
        nip: BubbleNip.leftBottom,
        color: Colors.yellow,
        child: Text(
          '${chatContent.content}',
          style: TextStyle(color: Colors.black),
          textAlign: TextAlign.left,
        ),
      ),
    ],
  );
}

Widget bubleImageFromFriend(ChatMessage chatContent) {
  return Column(
    children: [
      TimeAgo.isSameDay(chatContent.timeStamp)
          ? Container()
          : Text(
              '${TimeAgo.timeAgoSinceDate(chatContent.timeStamp)},',
              style:
                  TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
            ),
      Bubble(
          margin: BubbleEdges.only(top: 10.0),
          alignment: Alignment.topLeft,
          nip: BubbleNip.leftBottom,
          color: Colors.yellow,
          child: Column(
            children: [
              Image.network(chatContent.pictureLink),
              Text(
                '${chatContent.content}',
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.left,
              ),
            ],
          )),
    ],
  );
}
