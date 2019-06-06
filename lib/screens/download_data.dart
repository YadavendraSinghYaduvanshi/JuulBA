import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loreal_isp_supervisor_flutter/database/dbhelper.dart';
import 'package:loreal_isp_supervisor_flutter/gettersetter/all_gettersetter.dart';

class DownloadData extends StatefulWidget {
  @override
  _DownloadDataState createState() => _DownloadDataState();
}

class _DownloadDataState extends State<DownloadData>{
  var visit_date, user_id;
  String error_msg = "Network Error Please Try Again.";

  @override
  void initState() {
    // TODO: implement initState
    _loadCounter();

    super.initState();
  }

  //List<String> items = ["Table_Structure", "JOURNEY_PLAN_SUP", "NON_WORKING_REASON"];
  List<String> items = ["Table_Structure", "JOURNEY_PLAN_SUP","NON_WORKING_REASON", "DEVIATION_STORE_SUP"];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: new Color(0xffEEEEEE),
    );
  }

  _fetchData(var index) async {

    print("Attempting to fetch... " + items[index]);

    final url =
        "http://lipromo.parinaam.in/Webservice/Liwebservice.svc/GetAll";

    Map lMap = {
      "Downloadtype": items[index],
      "Username": user_id,
      "per1": "0",
      "per2": "0",
      "per3": "0",
      "per4": "0",
      "per5": "0",

    };

    try {
      String lData = json.encode(lMap);
      Map<String, String> lHeaders = {};
      lHeaders = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };
     await http.post(url, body: lData, headers: lHeaders).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
        var test = json.decode(response.body);

        //var test1 = json.decode(test);

        switch(items[index]){

          case "Table_Structure":

            List<Table_Structure> table_list=  parseTableStructure(response.body);

            //var data = test1['Table_Structure'];
            for(int i=0; i<table_list.length; i++){
              _create_table(table_list[i].SqlText);
            }

            break;

          case "JOURNEY_PLAN_SUP":

            if(test==""){
              error_msg = "No journey plan defined for today";
              //var test1 = json.decode(test);
            }

            //
            _insertData(response.body, "JOURNEY_PLAN_SUP");

            //List<JOURNEY_PLAN_SUP> table_list =  parseSUPJCP(response.body);

            break;

          case "NON_WORKING_REASON":
            _insertData(response.body, "NON_WORKING_REASON");
            break;

          case "DEVIATION_STORE_SUP":
            _insertData(response.body, "DEVIATION_STORE_SUP");
            break;
        }

        if(index+1 < items.length){
          _fetchData(++index);
        }
        else{
          Navigator.pop(context, DialogDemoAction.cancel);
          Navigator.of(context).pop();
        }

      });
    }catch(Exception){

      Navigator.pop(context, DialogDemoAction.cancel);
      var dialog = await _AlertDialog();
      if(dialog!=null){
        Navigator.of(context).pop();
      }
    }
  }

  Future<String> _AlertDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Alert'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(error_msg),
                //new Text('or Password'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Ok'),
              color: new Color(0xffEEEEEE),
              onPressed: () {
                Navigator.of(context).pop("ok");
              },
            ),
          ],
        );
      },
    );
  }

  //Loading counter value on start
  Future<String> _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    SharedPreferences.getInstance().then((SharedPreferences sp) {
      prefs = sp;
      visit_date = prefs.getString('CURRENTDATE');
      // will be null if never previously saved
    });
    visit_date = prefs.getString('CURRENTDATE');
    user_id = prefs.getString('Userid_Main');

    showDialog<DialogDemoAction>(
      context: context,
      barrierDismissible: false,
      child: new Dialog(
          child: new Padding(padding: EdgeInsets.all(25.0),
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
                new SizedBox(width: 20.0),
                new Text("Downloading", style: new TextStyle(fontSize: 18.0),),
              ],
            ),
          )
      ),
    );

    //var t1 = await _openDb();
    var t2 = await _fetchData(0);
  }

/*  DatabaseISP database;
  //Loading counter value on start
  _openDb() async {
    String path = await initDeleteDb();
    database = new DatabaseISP();
    await database.open(path);
    //await database.close();
  }*/

  _create_table(var query){
    //await database.create(query);
    var dbHelper = DBHelper();
    dbHelper.create_table(query);
  }

  _insertData(var responsebody, String table_name){
    //await database.insertData(responsebody, table_name);
    var dbHelper = DBHelper();
    dbHelper.insertData(responsebody, table_name);
  }
}

enum DialogDemoAction {
  cancel,
  discard,
  disagree,
  agree,
}


List<Table_Structure> parseTableStructure(String responseBody) {
  var test = json.decode(responseBody);
  List<Table_Structure> statusList = new List();

  if(test==""){
    return statusList;
  }
  var test1 = json.decode(test);
  var list = test1['Table_Structure'] as List;
   statusList =
  list.map((i) => Table_Structure.fromJson(i)).toList();

  return statusList;

  /* final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Promoter>((json) => Promoter.fromJson(json)).toList();*/
}

class Table_Structure {
  final String SqlText;

  Table_Structure(
      {this.SqlText});

  factory Table_Structure.fromJson(Map<String, dynamic> json) {
    return Table_Structure(
      SqlText: json['SqlText'] as String,
    );
  }
}

List<JOURNEY_PLAN_SUP> parseSUPJCP(String responseBody) {
  var test = json.decode(responseBody);

  var test1 = json.decode(test);
  var list = test1['JOURNEY_PLAN_SUP'] as List;
  List<JOURNEY_PLAN_SUP> statusList =
  list.map((i) => JOURNEY_PLAN_SUP.fromJson(i)).toList();

  return statusList;

  /* final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Promoter>((json) => Promoter.fromJson(json)).toList();*/
}

