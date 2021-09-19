import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:real_chat_fluttter/const/const.dart';
import 'package:real_chat_fluttter/model/user_model.dart';
import 'package:real_chat_fluttter/utils/utils.dart';

class RegisterScreen extends StatefulWidget {

  FirebaseApp app;
  RegisterScreen({this.app, this.user});

  User user;


  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Expanded(
               flex: 1,
               child: TextField(
                 controller:_firstNameController ,
                 keyboardType: TextInputType.name,
                 decoration: InputDecoration(
                   hintText: 'First Name',
                 ),
               ),
             ),
             SizedBox(
               width: 16,
             ),
             Expanded(
               flex: 1,
               child: TextField(
                 keyboardType: TextInputType.name,
                 controller:_lastNameController ,
                 decoration: InputDecoration(
                   hintText: 'Last Name',
                 ),
               ),
             )
           ],
         ),
            TextField(
              readOnly: true,
              controller:_phoneController ,
              decoration: InputDecoration(
                hintText: widget.user.phoneNumber ?? 'NULL',
              ),
            ),
            ElevatedButton(onPressed: (){
              if(_firstNameController.text == null || _firstNameController.text.isEmpty)
                showOnlySnackBar(context, "Please enter first name");
              else if(_lastNameController.text == null || _lastNameController.text.isEmpty)
                showOnlySnackBar(context, "Please enter last name");
              else {
                UserModel userModel = UserModel(firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                phone: widget.user.phoneNumber);


                //submit to firebase

                FirebaseDatabase(app: widget.app)
                .reference()
                .child(PEOPLE_REF)
                .child(widget.user.uid)
                .set(<String,dynamic>{
                 'firstName': userModel.firstName,
                  'lastName': userModel.lastName,
                  'phone': userModel.phone,
                })
                .then((value) {
                  showOnlySnackBar(context, 'Register Success');
                  Navigator.pop(context);
                }).catchError((e) => showOnlySnackBar(context, '$e'));
              }
            },
            child: Text("REGISTER",style: TextStyle(color: Colors.black),),)
          ],
        ),
      ),
    );
  }
}
