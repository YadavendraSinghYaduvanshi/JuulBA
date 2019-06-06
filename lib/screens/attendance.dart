import 'package:flutter/material.dart';
import 'package:loreal_isp_supervisor_flutter/utils/card_simple.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceList extends StatefulWidget {
  @override
  _AttendanceListState createState() => _AttendanceListState();
}

class _AttendanceListState extends State<AttendanceList> {

  String user_id, designation;

  @override
  void initState() {
    // TODO: implement initState
    _loadCounter();

    super.initState();
  }

  _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //visit_date = prefs.getString('CURRENTDATE');
    user_id = prefs.getString('Userid');
    designation = prefs.getString('Designation');

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Attendance"),
      ),
      backgroundColor: new Color(0xffEEEEEE),
      body: ListView(
        children: <Widget>[
          new GestureDetector(
            child:new MyCardSimple(
              title: new Text(
                "Day Wise Status on Attendance vs Day Wise Status on the Data upload",
                style: new TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
            onTap: () {
              print("attendance");
              Navigator.of(context).pushNamed('/PromoterList');
         /*     if(designation=="Supervisor"){
                Navigator.of(context).pushNamed('/PromoterList');
              }
              else{

              }*/

            },
          ),
          new GestureDetector(
            child:  new MyCardSimple(
              title: new Text(
                "Defaulters with 3 days absent",
                style: new TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
            onTap: (){
              Navigator.of(context).pushNamed('/AttendanceDefaulter3Days');
            },
          ),

          new GestureDetector(
            child: new MyCardSimple(
              title: new Text(
                "Defaulters with 5 days absent",
                style: new TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),

            ),
            onTap: (){
              Navigator.of(context).pushNamed('/AttendanceDefaulter5Days');
            },
          ),
          new GestureDetector(
            child:  new MyCardSimple(
              title: new Text(
                "Tgt vs Ach on Planned Logins as on date",
                style: new TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
            onTap:  (){
              Navigator.of(context).pushNamed('/AttendanceTgtVsAchPlannedLogins');
            },
          ),
          new MyCardSimple(
            title: new Text(
              "Vacancies as on date – Store Name comparison with the last Present date of 1st / 2nd / 3rd promoter in that store",
              style: new TextStyle(
                  color: Colors.grey,
                  fontSize: 20.0,
                  fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
