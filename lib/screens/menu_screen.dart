import 'package:flutter/material.dart';
import 'package:loreal_isp_supervisor_flutter/screens/groomingScreen.dart';
import 'package:loreal_isp_supervisor_flutter/screens/customer_engagement.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Menu'),
          backgroundColor: Colors.green[700],
        ),
        body: Container(
          margin: const EdgeInsets.only(top: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                child: Column(
                  children: <Widget>[
                    new Image(
                      image: new AssetImage('assets/grooming.png'),
                      height: 100.0,
                      width: 100.0,
                    ),
                    Text(
                      "Grooming",
                      style: new TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroomingScreen(),
                    ),
                  );
                },
              ),
              GestureDetector(
                child: Column(
                  children: <Widget>[
                    new Image(
                      image: new AssetImage('assets/customer_connect_.png'),
                      height: 100.0,
                      width: 100.0,
                    ),
                    Text(
                      "Customer Engagement",
                      style: new TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerEngagement(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
