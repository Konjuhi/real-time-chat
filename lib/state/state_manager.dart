import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_chat_fluttter/model/user_model.dart';

final chatUser = StateProvider((ref) => UserModel());

final userLogged = StateProvider((ref)=> UserModel());