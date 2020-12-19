import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_shop/assets/custom_icons.dart';
import '../auth/Authentication.dart';
import '../model/Users.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({
    this.auth,
    this.onSignedOut,
  });

  final AuthImplementation auth;
  final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  List<Users> usersList = [];

  String userId = "";
  String _description = "";

  @override
  void initState() {
    super.initState();

    inputData(userId);
  }

  void _logoutUser() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e.toString());
    }
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

//Undescribed function of saving / updating profile. Perhaps in the future it will be added

//Недописаная функция сохранения/обновления профиля. Возможно в будущем будет дописана

  // void saveToDatabase(_description) {
  //
  //   DatabaseReference ref = FirebaseDatabase.instance.reference();
  //
  //
  //   var data = {
  //     "description" : _description,
  //
  //   };
  //
  //   ref.child("Users").child(userId).push().set(data);
  // }

  void inputData(userId) async {
    final FirebaseUser user = await auth.currentUser();
    final userId = user.uid;
    // here you write the codes to input the data into firebase real-time database
    DatabaseReference userRef =
        FirebaseDatabase.instance.reference().child("Users").child(userId);

    userRef.once().then((DataSnapshot snap) {
      var KEYS = snap.value.keys;
      var DATA = snap.value;

      usersList.clear();

      for (var key in KEYS) {
        print("Key of KEYS: " + key);
        print("Key of snapshot: " + snap.key);

        Users users = new Users(
            key,
            DATA[key]['firstName'],
            DATA[key]['gender'],
            DATA[key]['image'],
            DATA[key]['lastName'],
            DATA[key]['uId']);

        usersList.add(users);
      }
      setState(() {
        print('Length: $usersList.length');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicTheme(
      theme: NeumorphicThemeData(
        defaultTextColor: Color(0xFF3E3E3E),
        accentColor: Colors.grey,
        variantColor: Colors.black38,
        depth: 8,
        intensity: 0.65,
      ),
      themeMode: ThemeMode.light,
      child: Material(
        child: NeumorphicBackground(
          child: Container(
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: usersList.length,
              itemBuilder: (context, index) {
                return Container(
                    key: Key(usersList[index].image),
                    child: cardUi(
                        usersList[index].id,
                        usersList[index].firstName,
                        usersList[index].gender,
                        usersList[index].image,
                        usersList[index].lastName,
                        usersList[index].uId));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget cardUi(String id, String firstName, String gender, String image,
      String lastName, String uId) {
    return SafeArea(
      child: Container(
        // height: double.infinity,
        // width:double.infinity,
        child: Column(
          children: <Widget>[
            Column(
              children: [
                // Container(
                //   margin: EdgeInsets.only(left: 12, right: 12, top: 10),
                // ),
                Neumorphic(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  style: NeumorphicStyle(
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Neumorphic(
                            padding: EdgeInsets.all(8),
                            style: NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.circle(),
                              depth: NeumorphicTheme.embossDepth(context),
                              // border: NeumorphicBorder(
                              //   color: Colors.cyan,
                              //   width: 2,
                              // ),
                            ),
                            child: Container(
                                width: 120.0,
                                height: 120.0,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: new NetworkImage(image),
                                    )))),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(lastName),
                            Row(
                              children: [
                                Text(
                                  "Gender - ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                gender == ("male")
                                    ? Icon(CustomIcons.male)
                                    : Icon(CustomIcons.female),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _TextField(
                label: "Write about you:",
                hint: "",
                onChanged: (value) {
                  setState(() {
                    this._description = value;
                  });
                }),
            SizedBox(
              height: 12,
            ),
            MaterialButton(
              child: Text(
                "Save",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              onPressed: () => {},
              // onPressed: () => saveToDatabase(_description),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatefulWidget {
  final String label;
  final String hint;

  final ValueChanged<String> onChanged;

  _TextField({@required this.label, @required this.hint, this.onChanged});

  @override
  __TextFieldState createState() => __TextFieldState();
}

class __TextFieldState extends State<_TextField> {
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.hint);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
          child: Text(
            this.widget.label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: NeumorphicTheme.defaultTextColor(context),
            ),
          ),
        ),
        Neumorphic(
          margin: EdgeInsets.only(left: 18, right: 18, top: 2, bottom: 4),
          style: NeumorphicStyle(
            depth: NeumorphicTheme.embossDepth(context),
            intensity: 0.80,
          ),
          // padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          child: Container(
            height: 170,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16)),
            ),
            child: TextField(
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: NeumorphicTheme.defaultTextColor(context),
              ),
              onChanged: this.widget.onChanged,
              controller: _controller,
              decoration: InputDecoration.collapsed(hintText: this.widget.hint),
            ),
          ),
        )
      ],
    );
  }
}
