import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:page_transition/page_transition.dart';
import 'package:real_chat_fluttter/screen/chat_screen.dart';
import 'package:real_chat_fluttter/screen/register_screen.dart';
import 'package:real_chat_fluttter/utils/utils.dart';

import 'const/const.dart';
import 'firebase_utils/firebase_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp(app: app)));
}

class MyApp extends StatelessWidget {
  FirebaseApp app;

  MyApp({this.app});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/register':
            return PageTransition(
                child: RegisterScreen(
                    app: app,
                    user:
                        FirebaseAuth.FirebaseAuth.instance.currentUser ?? null),
                type: PageTransitionType.fade,
                settings: settings);
            break;
          case '/detail':
            return PageTransition(
                child: ChatScreen(
                    app: app,
                    user:
                        FirebaseAuth.FirebaseAuth.instance.currentUser ?? null),
                type: PageTransitionType.fade,
                settings: settings);

          default:
            return null;
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', app: app),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.app}) : super(key: key);

  final String title;
  final FirebaseApp app;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  DatabaseReference _peopleRef, _chatListRef;
  FirebaseDatabase database;

  bool isUserInit = false;

  TabController _tabController;

  final List<Tab> tabs = <Tab>[
    Tab(
      icon: Icon(Icons.chat),
      text: 'Chats',
    ),
    Tab(
      icon: Icon(Icons.people),
      text: 'Friend',
    )
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _tabController = TabController(length: tabs.length, vsync: this);

    database = FirebaseDatabase(app: widget.app);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      processLogin(context);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff656565),
        bottom: TabBar(
          tabs: tabs,
          controller: _tabController,
          unselectedLabelColor: Colors.black45,
          labelColor: Colors.white,
          isScrollable: false,
        ),
      ),
      body: isUserInit
          ? TabBarView(
              controller: _tabController,
              children: tabs.map((Tab tab) {
                if (tab.text == 'Chat')
                  return loadChatList(database, _chatListRef);
                else
                  return loadPeople(database, _peopleRef);
              }).toList())
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  void processLogin(BuildContext context) async {
    var user = FirebaseAuth.FirebaseAuth.instance.currentUser;
    if (user == null) // if not login
    {
      FirebaseAuthUi.instance()
          .launchAuth([AuthProvider.phone()]).then((fbUser) async {
        //refresh state
        await _checkLoginState(context);
      }).catchError((e) {
        if (e is PlatformException) {
          if (e.code == FirebaseAuthUi.kUserCancelledError)
            showOnlySnackBar(context, 'User cancelled login');
          else {
            showOnlySnackBar(context, "${e.message ?? 'Unk error'}");
          }
        }
      });
    } else // Already Login
      await _checkLoginState(context);
  }

  Future<FirebaseAuth.User> _checkLoginState(BuildContext context) async {
    if (FirebaseAuth.FirebaseAuth.instance.currentUser != null) {
      //Already login, get token
      FirebaseAuth.FirebaseAuth.instance.currentUser.getIdToken().then((value)  async{
        _peopleRef = database.reference().child(PEOPLE_REF);

        _chatListRef = database
            .reference()
            .child(CHATLIST_REF)
            .child(FirebaseAuth.FirebaseAuth.instance.currentUser.uid);

        //Load information
        _peopleRef
            .child(FirebaseAuth.FirebaseAuth.instance.currentUser.uid)
            .once()
            .then((snapshot) {
          if (snapshot != null && snapshot.value != null) {
            setState(() {
              isUserInit = true;
            });
          } else {
            setState(() {
              isUserInit = true;
            });
            Navigator.pushNamed(context, '/register');
          }
        });
      });
    }

    return FirebaseAuth.FirebaseAuth.instance.currentUser;
  }
}
