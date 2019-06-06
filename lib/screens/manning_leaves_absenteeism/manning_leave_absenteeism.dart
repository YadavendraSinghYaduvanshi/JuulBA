import 'package:flutter/material.dart';
import 'package:loreal_isp_supervisor_flutter/utils/card_simple.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManningLeaveList extends StatefulWidget {
  @override
  _ManningLeaveListState createState() => _ManningLeaveListState();
}

class _ManningLeaveListState extends State<ManningLeaveList> {

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
        title: new Text("Manning/Leaves/Absenteeism"),
      ),
      backgroundColor: new Color(0xffEEEEEE),
      body: ListView(
        children: <Widget>[
          new GestureDetector(
            child:new MyCardSimple(
              title: new Text(
                "Recruitment TAT store wise – Calculated basis last present date of previous promoter",
                style: new TextStyle(
                    color: Colors.grey,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
            onTap: () {
              /* print("Performance");
              if(designation=="Supervisor"){
                Navigator.of(context).pushNamed('/PromoterList');
              }
              else{

              }*/

            },
          ),
          new GestureDetector(
            child:  new MyCardSimple(
              title: new Text(
                "Promoter wise day wise Login vs Logout time vs Time Spent inside the outlet",
                style: new TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
            onTap: (){
              Navigator.of(context).pushNamed('/DaywiseTimeSpent');
            },
          ),

          new GestureDetector(
            child: new MyCardSimple(
              title: new Text(
                "Promoter wise day wise average time spent",
                style: new TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),

            ),
            onTap: (){
              Navigator.of(context).pushNamed('/AverageTimeSpent');
            },
          ),
          new GestureDetector(
            child:  new MyCardSimple(
              title: new Text(
                "Store Wise Manned days of this month -Ach vs Targeted planned days till previous day",
                style: new TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
            onTap:  (){
             Navigator.of(context).pushNamed('/StorewiseManDays');
            },
          ),
          new GestureDetector(
            onTap: (){
              //Navigator.of(context).pushNamed('/OQADSellingSkills');
            },
            child:  new MyCardSimple(
              title: new Text(
                "Store wise Manned days data for last 6 months",
                style: new TextStyle(
                    color: Colors.grey,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ),
          new GestureDetector(
            child:  new MyCardSimple(
              title: new Text(
                "Promoter wise present days for last 6 months",
                style: new TextStyle(
                    color: Colors.grey,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
            onTap:  (){
              //Navigator.of(context).pushNamed('/PromoterWisePresentDays');
            },
          ),
          new GestureDetector(
            child:  new MyCardSimple(
              title: new Text(
                "Promoter wise present days for this month till previous day",
                style: new TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
            onTap:  (){
              Navigator.of(context).pushNamed('/PromoterWisePresentDays');
            },
          ),
          new GestureDetector(
            child:  new MyCardSimple(
              title: new Text(
                "Promoter Wise Month Wise Leaves Taken vs Leave Balance on the last day of previous month",
                style: new TextStyle(
                    color: Colors.grey,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
            onTap:  (){
              //Navigator.of(context).pushNamed('/OQADOverAll');
            },
          ),
        ],
      ),
    );
  }
}
