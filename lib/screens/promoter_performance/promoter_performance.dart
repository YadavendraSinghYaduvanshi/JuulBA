import 'package:flutter/material.dart';
import 'package:loreal_isp_supervisor_flutter/utils/card_simple.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceList extends StatefulWidget {
  @override
  _PerformanceListState createState() => _PerformanceListState();
}

class _PerformanceListState extends State<PerformanceList> {

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
        title: new Text("Performance"),
      ),
      backgroundColor: new Color(0xffEEEEEE),
      body: ListView(
        children: <Widget>[
          new GestureDetector(
            child:new MyCardSimple(
              title: new Text(
                "Promoter Wise Incentive Earned on each parameter vs the Slabs",
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
                "Over All Sales – Tgt vs Ach for last 6 months",
                style: new TextStyle(
                    color: Colors.grey,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
            onTap: (){
              //Navigator.of(context).pushNamed('/PerformanceDefaulter3Days');
            },
          ),

          new GestureDetector(
            child: new MyCardSimple(
              title: new Text(
                "Focus Pack - Tgt vs Ach for last 6 months",
                style: new TextStyle(
                    color: Colors.grey,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),

            ),
            onTap: (){
              //Navigator.of(context).pushNamed('/PerformanceDefaulter5Days');
            },
          ),
          new GestureDetector(
            child:  new MyCardSimple(
              title: new Text(
                "OQAD – Product Knowledge – Correct Responses vs total attempted",
                style: new TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
            onTap:  (){
              Navigator.of(context).pushNamed('/OQADProductKnowledge');
            },
          ),
          new GestureDetector(
            onTap: (){
              Navigator.of(context).pushNamed('/OQADSellingSkills');
            },
            child:  new MyCardSimple(
              title: new Text(
                "OQAD – Selling Skills – Correct Responses vs total attempted",
                style: new TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ),
          new GestureDetector(
            child:  new MyCardSimple(
              title: new Text(
                "OQAD – Over All – Correct Responses vs total attempted",
                style: new TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
            onTap:  (){
              Navigator.of(context).pushNamed('/OQADOverAll');
            },
          ),
        ],
      ),
    );
  }
}
