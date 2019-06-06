import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceDataUploadstatus extends StatefulWidget {
  String promoter_id;

  // In the constructor, require a Todo
  AttendanceDataUploadstatus({Key key, @required this.promoter_id})
      : super(key: key);

  @override
  _AttendanceDataUploadstatusState createState() =>
      _AttendanceDataUploadstatusState();
}

class _AttendanceDataUploadstatusState
    extends State<AttendanceDataUploadstatus> {
  String user_id, designation, promoter_id;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title:
              new Text("Attendance Data Upload Status - " + widget.promoter_id),
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
                            "JCP Date",
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
                            "Upload Status",
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
                            "Attendance",
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
                  child: FutureBuilder<List<ATTENDANCE_DATAUPLOAD_STATUS>>(
                future: fetchData("${widget.promoter_id}"),
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);
                  //_loadCounter();
                  return snapshot.hasData
                      ?(snapshot.data.length>0? StatusList(status: snapshot.data): new Center(child: new Card(child: new Container(margin: EdgeInsets.all(5.0),
                    child: new Text("No Data found", style: TextStyle(fontSize: 20.0),),),),))
                      : Center(child: CircularProgressIndicator());
                },
              ))
            ],
          ),
        ));
  }

  Future<List<ATTENDANCE_DATAUPLOAD_STATUS>> fetchData(
      String promoter_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //visit_date = prefs.getString('CURRENTDATE');
    user_id = prefs.getString('Userid');
    designation = prefs.getString('Designation');

    print("Attempting to fetch... PROMOTER_LIST ");

    final url = "http://lipromo.parinaam.in/Webservice/Liwebservice.svc/GetAll";

    Map lMap = {
      "Downloadtype": "ATTENDANCE_DATAUPLOAD_STATUS",
      "Username": user_id,
      "per1": designation,
      "per2": promoter_id,
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

List<ATTENDANCE_DATAUPLOAD_STATUS> parsePhotos(String responseBody) {
  var test = json.decode(responseBody);

  List<ATTENDANCE_DATAUPLOAD_STATUS> statusList = new List();
  if(test==""){
    return statusList;
  }

  var test1 = json.decode(test);
  var list = test1['ATTENDANCE_DATAUPLOAD_STATUS'] as List;
  statusList =
      list.map((i) => ATTENDANCE_DATAUPLOAD_STATUS.fromJson(i)).toList();

  return statusList;

  /* final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Promoter>((json) => Promoter.fromJson(json)).toList();*/
}

class ATTENDANCE_DATAUPLOAD_STATUS {
  final String JCP_DATE;
  final String DATA_UPLOAD;
  final String ATTENDANCE_STATUS;

  ATTENDANCE_DATAUPLOAD_STATUS(
      {this.JCP_DATE, this.DATA_UPLOAD, this.ATTENDANCE_STATUS});

  factory ATTENDANCE_DATAUPLOAD_STATUS.fromJson(Map<String, dynamic> json) {
    return ATTENDANCE_DATAUPLOAD_STATUS(
      JCP_DATE: json['JCP_DATE'] as String,
      DATA_UPLOAD: json['DATA_UPLOAD'] as String,
      ATTENDANCE_STATUS: json['ATTENDANCE_STATUS'] as String,
    );
  }
}

class StatusList extends StatelessWidget {
  final List<ATTENDANCE_DATAUPLOAD_STATUS> status;

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
                    builder: (context) => AttendanceDataUploadstatus(promoter_id: status[index].JCP_DATE),
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
                    status[index].JCP_DATE,
                    style: new TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontStyle: FontStyle.normal),
                  ),
                )),
                new Expanded(
                    child: new Center(
                  child: new Text(
                    status[index].DATA_UPLOAD,
                    style: new TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontStyle: FontStyle.normal),
                  ),
                )),
                new Expanded(
                    child: new Center(
                  child: new Text(
                    status[index].ATTENDANCE_STATUS,
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
