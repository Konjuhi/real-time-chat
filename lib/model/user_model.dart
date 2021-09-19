
class UserModel{
  String uid;
  String firstName;
  String lastName;
  String phone;

  UserModel({this.firstName,this.lastName,this.phone});

  UserModel.fromJson(Map<String,dynamic> json)
  {
    uid = json['uid'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    phone = json['phone'];
  }

  Map<String,dynamic> toJson(){
    final Map<String,dynamic> data = Map<String,dynamic>();
    data['firstName']= this.firstName;
    data['lastName']= this.lastName;
    data['phone']= this.phone;
    data['uid'] = this.uid;
    return data;
  }

}

