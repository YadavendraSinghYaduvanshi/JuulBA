import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceTgtVsAchPlannedLogins extends StatefulWidget {
/*
  String promoter_id;

  // In the constructor, require a Todo
  AttendanceTgtVsAchPlannedLogins({Key key, @required this.promoter_id})
      : super(key: key);
*/

  @override
  _AttendanceTgtVsAchPlannedLoginsState createState() =>
      _AttendanceTgtVsAchPlannedLoginsState();
}

class _AttendanceTgtVsAchPlannedLoginsState
    extends State<AttendanceTgtVsAchPlannedLogins> {
  String user_id, designation, promoter_id;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title:
          new Text("Tgt vs Ach on Planned Logins as on date"),
        ),
        body: Container(
          decoration: new BoxDecoration(
            color: new Color(0xffEEEEEE),
          ),
          child: new Column(
            children: <Widget>[
              new Card(
                child: new Container(
                  margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0
                  ),
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new Center(
                          child: new Text(
                            "Promoter",
                            style: new TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontStyle: FontStyle.normal),
                          ),
                        ),
                      ),
                      new Expanded(
                        child: new Center(
                          child: new Text(
                            "Planned",
                            style: new TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontStyle: FontStyle.normal),
                          ),
                        ),
                      ),
                      new Expanded(
                        child: new Center(
                          child: new Text(
                            "Covered",
                            style: new TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontStyle: FontStyle.normal),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              new Expanded(
                  child: FutureBuilder<List<TARGET_VS_ACH_PLANNED_LOGINS>>(
                    future: fetchData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) print(snapshot.error);
                      //_loadCounter();
                      return snapshot.hasData
                          ? (snapshot.data.length>0? StatusList(status: snapshot.data): new Center(child: new Card(child: new Container(margin: EdgeInsets.all(5.0),
                        child: new Text("No Data found", style: TextStyle(fontSize: 20.0),),),),))
                          : Center(child: CircularProgressIndicator());
                    },
                  ))
            ],
          ),
        ));
  }

  Future<List<TARGET_VS_ACH_PLANNED_LOGINS>> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //visit_date = prefs.getString('CURRENTDATE');
    user_id = prefs.getString('Userid');
    designation = prefs.getString('Designation');

    print("Attempting to fetch... PROMOTER_LIST ");

    final url = "http://lipromo.parinaam.in/Webservice/Liwebservice.svc/GetAll";

    Map lMap = {
      "Downloadtype": "TARGET_VS_ACH_PLANNED_LOGINS",
      "Username": user_id,
      "per1": designation,
      "per2": user_id,
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

    //http.post(url, body: lData, headers: lHeaders).then((response) {
    var response = await http.post(url, body: lData, headers: lHeaders);
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    // Use the compute function to run parsePhotos in a separate isolate
    return compute(parsePhotos, response.body);
  }
}

List<TARGET_VS_ACH_PLANNED_LOGINS> parsePhotos(String responseBody) {
  var test = json.decode(responseBody);
  List<TARGET_VS_ACH_PLANNED_LOGINS> statusList = new List();
  if(test==""){
    return statusList;
  }

  var test1 = json.decode(test);
  var list = test1['TARGET_VS_ACH_PLANNED_LOGINS'] as List;
  statusList =
  list.map((i) => TARGET_VS_ACH_PLANNED_LOGINS.fromJson(i)).toList();

  return statusList;

  /* final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Promoter>((json) => Promoter.fromJson(json)).toList();*/
}

class TARGET_VS_ACH_PLANNED_LOGINS {
  final String PROMOTER;
  final int PLANNED;
  final int COVERED;

  TARGET_VS_ACH_PLANNED_LOGINS(
      {this.PROMOTER, this.PLANNED, this.COVERED});

  factory TARGET_VS_ACH_PLANNED_LOGINS.fromJson(Map<String, dynamic> json) {
    return TARGET_VS_ACH_PLANNED_LOGINS(
      PROMOTER: json['PROMOTER'] as String,
      PLANNED: json['PLANNED'] as int,
      COVERED: json['COVERED'] as int,
    );
  }
}

class StatusList extends StatelessWidget {
  final List<TARGET_VS_ACH_PLANNED_LOGINS> status;

  StatusList({Key key, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: status.length,
      itemBuilder: (context, index) {
        return new Card(
            child: new GestureDetector(
              onTap: () {
                print("attendance");
                /* Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceTgtVsAchPlannedLogins(promoter_id: status[index].JCP_DATE),
                  ),
                );*/
              },
              child: new Container(
                margin: EdgeInsets.all(10.0),
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                        child: new Center(
                          child: new Text(
                            status[index].PROMOTER,
                            style: new TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontStyle: FontStyle.normal),
                          ),
                        )),
                    new Expanded(
                        child: new Center(
                          child: new Text(
                            status[index].PLANNED.toString(),
                            style: new TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontStyle: FontStyle.normal),
                          ),
                        )),
                    new Expanded(
                        child: new Center(
                          child: new Text(
                            status[index].COVERED.toString(),
                            style: new TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontStyle: FontStyle.normal),
                          ),
                        )),
                  ],
                ),
              ),
            ));
      },
    );
  }
}
