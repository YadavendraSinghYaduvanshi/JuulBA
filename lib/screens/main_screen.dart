import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loreal_isp_supervisor_flutter/database/database.dart';
import 'store_list.dart';
import 'supervisor_list.dart';
import 'package:loreal_isp_supervisor_flutter/screens/menu_screen.dart';

import 'package:async/async.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Main_Activity extends StatefulWidget {
  @override
  _Main_ActivityState createState() => _Main_ActivityState();
}

class _Main_ActivityState extends State<Main_Activity>
    with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    _loadCounter();

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  _fetchData(String user_id) {

    print("Attempting to fetch... ");

    final url =
        "http://lipromo.parinaam.in/Webservice/Liwebservice.svc/GetAll";

    Map lMap = {
      "Downloadtype": "CITY_MASTER",
      "Username": user_id,
      "per1": "0",
      "per2": "0",
      "per3": "0",
      "per4": "0",
      "per5": "0",

  };

    String lData = json.encode(lMap);
    Map<String, String> lHeaders = {};
    lHeaders = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };
    http.post(url, body: lData, headers: lHeaders).then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      var test = json.decode(response.body);

      //var test1 = json.decode(test);

    });
  }

  var notice_url = "http://gskgtm.parinaam.in/notice/notice.html";
  var visit_date;
  static var userId, designation;

  static BuildContext context_global;

  static var profile_name = "";

  static final profile = new Container(
        height: 150.0,
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("assets/nav_bg.png"),
            fit: BoxFit.cover,
          ),
        ),

        child: new Center(
          child: new Column(
            children: <Widget>[
              new Center(
                  child: new Container(
                child: new Center(
                  child: new Image(
                    image: new AssetImage('assets/juul_logo.png'),
                    height: 100.0,
                    width: 100.0,
                  ),
                ),
                height: 100.0,
              )),
              new SizedBox(height: 10.0),
              new Text(profile_name,
                  style: new TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontStyle: FontStyle.normal)),
            ],
          ),
        ));

  static Text home = new Text("Reports",
      style: new TextStyle(
          color: Colors.blue, fontSize: 20.0, fontStyle: FontStyle.normal));

  static final home_parent = new GestureDetector(
      onTap: () {
        print("Reports clicked");
        Navigator.of(context_global).pop();
        if(designation=="Supervisor"){

          setSupervisor(userId, designation);
          Navigator.of(context_global).pushNamed('/Reports');

        }
        else{
          //Navigator.of(context_global).pushNamed('/SupervisorList');
          Navigator.push(
            context_global,
            MaterialPageRoute(
              builder: (context) => SupervisorList(),
            ),
          );
        }

      },
      child: new Container(
        child: new Row(children: <Widget>[
          new CircleAvatar(
            backgroundImage: new AssetImage('assets/reports.png'),
            radius: 20.0,
          ),
          new SizedBox(width: 10.0),
          home
        ]),
      ));

  //set preference data
  static Future setSupervisor(var user_id, var designation) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('Userid', user_id);
    await prefs.setString('Designation', designation);

  }

  static Text daily_entry = new Text("Daily Entry",
      style: new TextStyle(
          color: Colors.blue, fontSize: 20.0, fontStyle: FontStyle.normal));

  static final dialy_parent = new GestureDetector(
      onTap: () {
        print("Daily entry clicked");
        Navigator.of(context_global).pop();
        //Navigator.of(context_global).pushNamed('/StoreList');
        Navigator.push(
          context_global,
          MaterialPageRoute(
            builder: (context) => MenuScreen(),
          ),
        );
      },
      child: new Container(
        child: new Row(children: <Widget>[
          new CircleAvatar(
            backgroundImage: new AssetImage('assets/daily_entry.png'),
            radius: 20.0,
          ),
          new SizedBox(width: 10.0),
          daily_entry
        ]),
      ));

  static Text groups = new Text("Geotag",
      style: new TextStyle(
          color: Colors.blue, fontSize: 20.0, fontStyle: FontStyle.normal));

  static final groups_parent = new GestureDetector(
      onTap: () {
        print("Mark Attendance");
        Navigator.of(context_global).pop();
        //Navigator.of(context_global).pushNamed('/MarkAttendance');
        print("Download");
        Navigator.of(context_global).pushNamed('/geotagstore');
      },
      child: new Container(
        child: new Row(children: <Widget>[
          new CircleAvatar(
            backgroundImage: new AssetImage('assets/deviation.png'),
            radius: 20.0,
          ),
          new SizedBox(width: 10.0),
          groups
        ]),
      ));

  static Text download_txt = new Text("Download Data",
      style: new TextStyle(
          color: Colors.blue, fontSize: 20.0, fontStyle: FontStyle.normal));

  static final download = new GestureDetector(
      onTap: () {
        Navigator.of(context_global).pop();
        print("Download");
        Navigator.of(context_global).pushNamed('/Download');
      },
      child:  new Container(
        child: new Row(children: <Widget>[
          new CircleAvatar(
            backgroundImage: new AssetImage('assets/download.png'),
            radius: 20.0,
          ),
          new SizedBox(width: 10.0),
          download_txt
        ]),
      ));

  static Text sections = new Text("Exit",
      style: new TextStyle(
          color: Colors.blue, fontSize: 20.0, fontStyle: FontStyle.normal));

  static final sections_parent = new GestureDetector(
      onTap: () {
        Navigator.of(context_global).pop();
        print("Sections clicked");
        //Navigator.of(context_global).pushNamed('/DataTest');

        // ignore: implicit_this_reference_in_initializer
        _exitDialog();
      },
      child: new Container(
        child: new Row(children: <Widget>[
          new CircleAvatar(
            backgroundImage: new AssetImage('assets/exit.png'),
            radius: 20.0,
          ),
          new SizedBox(width: 10.0),
          sections
        ]),
      ));

  static var pad = const EdgeInsets.only(left: 8.0, right: 8.0, top: 20.0);
  static Padding padding2 = new Padding(
    padding: pad,
    child: home_parent,
  );
  static Padding padding3 = new Padding(
    padding: pad,
    child: groups_parent,
  );
  static Padding padding4 = new Padding(
    padding: pad,
    child: download,
  );
  static Padding padding5 = new Padding(
    padding: pad,
    child: sections_parent,
  );
  static Padding padding6 = new Padding(
    padding: pad,
    child: dialy_parent,
  );

  static var children = [
    profile,
    padding6,
    padding2,
    padding3,
    padding4,
    padding5,
    padding6,
  ];
  static ListView listview = new ListView(children: children);
  Drawer drawer = new Drawer(
    child: listview,
  );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  didPopRoute() {
    bool override;

    override = true;
    return new Future<bool>.value(override);
  }

  @override
  Widget build(BuildContext context) {
    context_global = context;
    return new Scaffold(
      drawer: drawer,
      appBar: new AppBar(
        title: new Text("Juul Brand Ambassador"),
        backgroundColor: Colors.blue,
      ),
      body: new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("assets/background2.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        /*height: 300.0,
        width: 100.0,
        child: new WebviewScaffold(url: notice_url,
          appBar: new AppBar(
            title: new Text("Loreal ISP Supervisor"),
            backgroundColor: Colors.blue,
          ),
          withJavascript: true,
          withLocalStorage: true,
        ),*/
      ),
    );
  }

  //Loading counter value on start
   _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    visit_date = prefs.getString('CURRENTDATE');
    notice_url = prefs.getString('Notice');
    userId = prefs.getString('Userid_Main');
    designation = prefs.getString('Designation_Main');
    //_fetchData(userId);
  }

  static Future<Null> _exitDialog() async {
    return showDialog<Null>(
      context: context_global,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Alert'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('Want to exit app'),
                //new Text('or Password'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Cancel'),
              color: new Color(0xffEEEEEE),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text('Ok'),
              color: new Color(0xffEEEEEE),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/Login', (Route<dynamic> route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  //Loading counter value on start
  _insert(var query) async {
    String path = await initDeleteDb();
    DatabaseISP database = new DatabaseISP();
    await database.open(path);

    await database.create(query);

    await database.close();
  }
}
