import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance_screens/attendance_data_upload_status_screen.dart';

class SupervisorList extends StatefulWidget {
  @override
  _SupervisorListState createState() => _SupervisorListState();
}

class _SupervisorListState extends State<SupervisorList> {

  String user_id, designation;

  _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //visit_date = prefs.getString('CURRENTDATE');
    user_id = prefs.getString('Userid');
    designation = prefs.getString('Designation');

    //fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Supervisor List"),
        ),
        body: Container(
          color: new Color(0xffEEEEEE),
          child: FutureBuilder<List<SUPERVISOR_DATA>>(
            future: SupervisorListData.length >0?SupervisorListData:fetchData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) print(snapshot.error);
              //_loadCounter();
              return snapshot.hasData
                  ? (snapshot.data.length>0?PromotersList(supervisor: snapshot.data): new Center(child: new Card(child: new Container(margin: EdgeInsets.all(5.0),
                child: new Text("No Data found", style: TextStyle(fontSize: 20.0),),),),))
                  : Center(child: CircularProgressIndicator());
            },
          ),
        )
    );
  }

  Future<List<SUPERVISOR_DATA>> fetchData() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    //visit_date = prefs.getString('CURRENTDATE');
    user_id = prefs.getString('Userid_Main');
    designation = prefs.getString('Designation_Main');

    print("Attempting to fetch... SUPERVISOR_LIST ");

    final url =
        "http://lipromo.parinaam.in/Webservice/Liwebservice.svc/GetAll";

    Map lMap = {
      "Downloadtype": "SUPERVISOR_LIST",
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
    /*   print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
     *//* var test = json.decode(response.body);

      var test1 = json.decode(test);
      var list = test1['PROMOTER_LIST'] as List;
      List<Promoter> SupervisorList = list.map((i) => Promoter.fromJson(i)).toList();
*//*
      //List<Promoter> data = json.decode(test)['PROMOTER_LIST'];

      //return SupervisorList;

      // Use the compute function to run parsePhotos in a separate isolate
      return compute(parsePhotos, response.body);
    });*/

    // Use the compute function to run parsePhotos in a separate isolate
    return compute(parsePhotos, response.body);
  }
}

List<SUPERVISOR_DATA> SupervisorListData = new List();
// A function that will convert a response body into a List<Photo>
List<SUPERVISOR_DATA> parsePhotos(String responseBody) {

  var test = json.decode(responseBody);
  SupervisorListData = new List();
  if(test==""){
    return SupervisorListData;
  }

  var test1 = json.decode(test);
  var list = test1['SUPERVISOR_LIST'] as List;
  SupervisorListData = list.map((i) => SUPERVISOR_DATA.fromJson(i)).toList();

  return SupervisorListData;

  /* final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Promoter>((json) => Promoter.fromJson(json)).toList();*/
}

class SUPERVISOR_DATA {
  final String USERNAME;
  final String SUPERVISOR;
  final int EMP_CD;

  SUPERVISOR_DATA({this.USERNAME, this.SUPERVISOR, this.EMP_CD});

  factory SUPERVISOR_DATA.fromJson(Map<String, dynamic> json) {
    return SUPERVISOR_DATA(
      USERNAME: json['USERNAME'] as String,
      SUPERVISOR: json['SUPERVISOR'] as String,
      EMP_CD: json['EMP_CD'] as int,
    );
  }
}

class PromotersList extends StatelessWidget {
  final List<SUPERVISOR_DATA> supervisor;

  PromotersList({Key key, this.supervisor}) : super(key: key);

  //set preference data
  Future _setSupervisor(var user_id, var designation) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

   await prefs.setString('Userid', user_id);
   await prefs.setString('Designation', designation);

  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: supervisor.length,
      itemBuilder: (context, index) {
        return new Card(
            child: new GestureDetector(
              onTap: () {
                print("Supervisor");

                _setSupervisor(supervisor[index].USERNAME, "Supervisor");

               /* Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceDataUploadstatus(promoter_id: supervisor[index].USERNAME),
                  ),
                );*/

                Navigator.of(context).pushNamed('/Reports');
              },
              child: new Container(
                margin: EdgeInsets.all(10.0),
                child: new Text(supervisor[index].SUPERVISOR,style: new TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontStyle: FontStyle.normal),),
              ),
            )
        );
      },
    );
  }
}


