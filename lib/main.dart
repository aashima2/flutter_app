import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Dynamic form'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = new TextEditingController();
  DateTime _date = new DateTime.now();
  bool value1 = false;
  bool value2 = false;


  String _dateformat ;

  var items = ['Male', 'Female', 'Rather nor say'];

  List<Container> myForms = [];

  var d;
  String Name;
  String Age;
  String Email;
  String Phonenumber;

  var type = '';
  Map data;

  double Rating;

//String url = 'https://api.myjson.com/bins/gj89b';
  Future getData() async {
    http.Response response =
        await http.get('https://api.myjson.com/bins/1cdtvh');
    debugPrint(response.body);
    data = json.decode(response.body);
    debugPrint(data["fields"].toString());
    debugPrint(data["fields"][0].toString());
    buildForm();
  }

  Future<Null> _selectdate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1996),
      lastDate: DateTime(2024),
    );
    if (picked != null && picked != _date) {
      print(picked);
      setState(() {
        print(_date);
        _date = picked;
        print(picked);
        _dateformat = "${picked.month}/${picked.day}/${picked.year}";
        print(_dateformat);
      });
    }
  }


  @override
  void initState() {
    _dateformat = "${_date.month}/${_date.day}/${_date.year}";


    getData();
  }

  int i;
  int j;
 adddata(){
   CollectionReference reference = Firestore.instance.collection("userdata");
   reference.add({
     "Name" : Name,
     "Gender": _controller.text,
     "age": Age,
     "EmailAddress": Email,
     "Phonenumber": Phonenumber,
     "Rating": Rating,
     "Date of visit": _dateformat,
   });
 }
  buildForm() {
    for (int val = 0; val < data["fields"].length; val++) {
      String value = data["fields"][val]["type" ];
      print(value);
//       String id  = data["fields"][val]["id"];
//      print(id);
      switch (value) {
        case "short_text":
          myForms.add(Container(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                onSaved: (String name) {
                  Name = name;

                  print(Name);
                },
                validator: (d) {
                  if (d.isEmpty ||
                      RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(d)) {
                    return 'Please fill data';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    hintText: data["fields"][val]["title"],
                    border: OutlineInputBorder()),
                maxLength: 20,
              ),
            ),
          ));
          break;
        case "dropdown":
          myForms.add(Container(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      validator: (d) {
                        if (d.isEmpty) return "Fill gender correctly";
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: data["fields"][val]["title"],
                          border: OutlineInputBorder()),
                    ),
                  ),
                  PopupMenuButton<String>(
                      icon: const Icon(Icons.arrow_drop_down),
                      onSelected: (String value) {
                        _controller.text = value;
                        print(_controller.text);
                      },
                      itemBuilder: (BuildContext context) {
                        return items.map<PopupMenuItem<String>>((String value) {
                          return new PopupMenuItem(
                              child: new Text(value), value: value);
                        }).toList();
                      })
                ],
              ),
            ),
          ));
          break;
        case "number":
          myForms.add(Container(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                onSaved: (String age) {
                  Age = age;
                  print(Age);
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(2),
                ],
                keyboardType: TextInputType.number,
                validator: (d) {
                  final isDigitsOnly = int.tryParse(d);
                  if (isDigitsOnly == null || isDigitsOnly == 0)
                    return " Fill the Age correctly";
                  return null;
                },
                decoration: InputDecoration(
                  hintText: data["fields"][val]["title"],
                  border: OutlineInputBorder(),
                ),
                maxLength: 2,
              ),
            ),
          ));
          break;
        case "email":
          myForms.add(Container(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                onSaved: (String email) {
                  Email = email;
                  print(Email);
                },
                keyboardType: TextInputType.emailAddress,
                validator: (d) {
                  Pattern pattern =
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@'
                      r'((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                  RegExp regex = new RegExp(pattern);
                  if (!regex.hasMatch(d))
                    return 'Enter Valid Email';
                  else
                    return null;
                },
                decoration: InputDecoration(
                    hintText: data["fields"][val]["title"],
                    border: OutlineInputBorder()),
              ),
            ),
          ));
          break;
        case "phone_number":
          myForms.add(Container(
            child: Padding(
              padding: const EdgeInsets.all(17.0),
              child: TextFormField(
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                ],
                keyboardType: TextInputType.number,
                onSaved: (String phonenumber) {
                  Phonenumber = phonenumber;
                  print(phonenumber);
                },
                validator: (d) {
                  String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                  RegExp regExp = new RegExp(patttern);
                  if (d.isEmpty) {
                    return 'Please enter mobile number';
                  }
                  else if (!regExp.hasMatch(d)) {
                    return 'Please enter valid mobile number';
                  }
                  return null;

                  },
                decoration: InputDecoration(
                    hintText: data["fields"][val]["title"],
                    border: OutlineInputBorder()),
                maxLength: 10,
              ),
            ),
          ));
          break;
        case "rating":
          myForms.add(Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(data["fields"][val]["title"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0),),
                ),
                FlutterRatingBar(
                  initialRating: 3,
                    fillColor: Colors.orange,
                    borderColor: Colors.orange.withAlpha(50),
                    allowHalfRating: true,
                    onRatingUpdate: (rating){
                    Rating = rating;
                    print(rating);
                    }
                ),
              ],
            ),

          ));
          break;
          case "date":
          myForms.add(Container(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text(
                    data["fields"][val]["title"],
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0),
                  ),
                ),
                Text(
                   _dateformat
                ),
                Padding(
                  padding: const EdgeInsets.only(left : 75.0),
                  child: IconButton(
                      icon: Icon(Icons.calendar_today),

                      onPressed: () {
                        _selectdate(context);
                      }),
                )
              ],
            ),
          ));
          break;
          case "yes_no":
          myForms.add(Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    data["fields"][val]["title"],
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text("yes"),
                        Checkbox(
                            value: value1,
                            onChanged: (bool valueyes) {
                              setState(() {
                                value1 = valueyes;
                                print(value1);
                              });

                            }),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text("No"),
                            Checkbox(
                                value: value2,
                                onChanged: (bool valueno) {
                                  setState(() {
                                    value2 = valueno;
                                    print(value2);

                                  });
                                }),
                          ],
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ));
      }
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  ...myForms,
                  FlatButton(
                    child: Text("Submit"),
                    onPressed: () {
                      if (!_formKey.currentState.validate()) {
                        return;
                      }
                      _formKey.currentState.save();
                      adddata();

                    },
                  )
                ],
              ),
            )));
  }
}
