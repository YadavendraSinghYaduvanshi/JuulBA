import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loreal_isp_supervisor_flutter/utils/anim_hero.dart';
import 'login_new.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    goToHomePage();
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      child: Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("assets/background3.jpg"),
            fit: BoxFit.cover,
          ),
        ),

        child: new ListView(
          children: <Widget>[
            /* new Image(
            image: new AssetImage('assets/anim.gif'),
            height: 200.0,
            width: 200.0,
          ),*/
            new Container(
              margin: new EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
              child: new Image(
                image: new AssetImage('assets/juul.gif'),
                height: 200.0,
                width: 200.0,
              ),
            ),

            new Container(
              margin: new EdgeInsets.symmetric(vertical: 20.0),
              child: new Center(
                child: new Image(
                  image: new AssetImage('assets/juul_logo.png'),
                  height: 200.0,
                  width: 200.0,
                ),
              ),
            ),

          ],
        ),
      )
    );
  }

  Future goToHomePage() async {
    await new Future.delayed(const Duration(milliseconds: 7000));
   /* Navigator.of(context).pop();
    Navigator.of(context).push(new AppPageRoute(builder: (BuildContext context) => new LoginNew()));*/

    //Route route = MaterialPageRoute(builder: (context) => MyPermissionClass());
    Route route = MaterialPageRoute(builder: (context) => LoginNew());
    Navigator.pushReplacement(context, route);
  }
}



/*class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}



class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  Animation<double> _mainLogoAnimation;
  AnimationController _mainLogoAnimationController;

  @override
  void initState() {
    super.initState();
    goToHomePage();
    _mainLogoAnimationController = new AnimationController(duration: new Duration(milliseconds: 3000) ,vsync: this);
    _mainLogoAnimation = new CurvedAnimation(parent:
    _mainLogoAnimationController, curve: Curves.easeIn);
    _mainLogoAnimation.addListener(() => (this.setState(() {})));
    _mainLogoAnimationController.forward();
  }


  @override
  Widget build(BuildContext context) {
    return new Material(
        color: Colors.white,
        child: new Center(
            child: new Opacity(
                opacity: 1.0 * _mainLogoAnimation.value,
                child: new Hero(
                    tag: 'tbh_logo',
                    child: new Image(
                        image: new AssetImage('assets/loreal1.png'),
                        width: 300.0
                    )
                )
            )
        )
    );
  }

  Future goToHomePage() async {
    await new Future.delayed(const Duration(milliseconds: 4000));
    Navigator.of(context).push(new AppPageRoute(builder: (BuildContext context) => new LoginNew()));
  }
}*/


/*
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData.dark(),
      home: new SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State createState() => new MyHomePageState();
}

class MyHomePageState extends State<SplashScreen> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<int> _animation;

  @override
  void initState() {
    _controller = new AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat();
    _animation = new IntTween(begin: 0, end: 116).animate(_controller);
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new AnimatedBuilder(
            animation: _animation,
            builder: (BuildContext context, Widget child) {
              String frame = _animation.value.toString().padLeft(3, '0');
              return new Image.asset(
                'assets/anim.gif',
                gaplessPlayback: true,
              );
            },
          ),
          new Text('Image: Guillaume Kurkdjian', style: new TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}*/
