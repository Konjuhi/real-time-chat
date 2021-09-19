import 'dart:async';

import 'package:flutter/material.dart';
import 'package:real_chat_fluttter/model/user_model.dart';

void showOnlySnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('$message'),
    action: SnackBarAction(
      label: 'OK',
      onPressed: () => Navigator.of(context).pop(),
    ),
  ));
}

String getRoomId(String a, String b) {
  if (a.compareTo(b) > 0)
    return a + b;
  else
    return b + a;
}

String createName(UserModel user) {
  return "${user.firstName} ${user.lastName}";
}

void autoScroll(ScrollController scrollController) {
  Timer(Duration(milliseconds: 100), () {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 100), curve: Curves.easeOut);
  });
}

void autoScrollRevers(ScrollController scrollController) {
  Timer(Duration(milliseconds: 100), () {
    scrollController.animateTo(0,
        duration: Duration(milliseconds: 100), curve: Curves.easeOut);
  });
}
