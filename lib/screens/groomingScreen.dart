import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import 'dart:async';
import 'package:loreal_isp_supervisor_flutter/database/dbhelper.dart';
import 'package:loreal_isp_supervisor_flutter/gettersetter/all_gettersetter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as Im;

class GroomingScreen extends StatefulWidget {
  @override
  _GroomingScreenState createState() => _GroomingScreenState();
}

class _GroomingScreenState extends State<GroomingScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String visit_date, user_id;
  String result_path;

  @override
  void initState() {
    // TODO: implement initState
    _loadCounter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text("Hygiene and Grooming"),
        ),
        body: new Container(
            color: new Color(0xffEEEEEE),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Container(
                  margin:
                  new EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                  child: new RaisedButton(
                      color: Colors.blue,
                      child: new Text(
                         "Please take your full length photo",
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                      onPressed: () {}),
                ),
                new Expanded(
                    child: new GestureDetector(
                        child: new Card(
                          child: new Container(
                            child: Center(
                              child: result_path != null && filePath != null
                                  ? new Image(
                                image: FileImage(new File(filePath)),
                              )
                                  : new Image(
                                image: new AssetImage(
                                    'assets/camera_icon.png'),
                                height: 100.0,
                                width: 100.0,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          String img_type = "Checkout_Image";
                          opencamera(1, img_type);
                        })),
                new Container(
                  margin:
                  new EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                  child: new RaisedButton(
                      color: Colors.blue,
                      child: new Text(
                        "Save",
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                      onPressed: () {
                        if (result_path != null) {
                          //insertStoreData(widget.store_data, result_path);
                          insertGroomingData(null, result_path, 0);
                          //compressImage(null, filePath);
                          //Navigator.of(context).pop();
                        } else {
                          showInSnackBar('Please click image');
                        }

                        //Navigator.of(context).pushNamed('/Second');
                        // _onLoading(context);
                      }),
                )
              ],
            )));
  }

  //Loading counter value on start
  Future _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    SharedPreferences.getInstance().then((SharedPreferences sp) {
      prefs = sp;
      visit_date = prefs.getString('CURRENTDATE');
      user_id = prefs.getString('Userid_Main');
      // will be null if never previously saved
    });
    visit_date = prefs.getString('CURRENTDATE');
    user_id = prefs.getString('Userid');

    /*if (store_data.UPLOAD_STATUS == "I") {
      var dbHelper = DBHelper();
      coverage = await dbHelper.getCoverage(visit_date, store_data.STORE_CD);
    }*/
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  List<CameraDescription> cameras;
  String filePath;

  Future<Null> opencamera(int store_cd, String img_type) async {
    // Fetch the available cameras before initializing the app.
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }

    //name of image clicked
    result_path = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraExampleHome(
          cameras: cameras,
          store_cd: store_cd,
          user_id: user_id.replaceAll(".", "_"),
          image_type: img_type,
        ),
      ),
    );

    if (result_path != null) {
      final Directory extDir = await getExternalStorageDirectory();
      final String dirPath = '${extDir.path}/Pictures/Loreal_ISP_SUP_IMG';
      filePath = '$dirPath/' + result_path;

      /*     showDialog<DialogDemoAction>(
        context: context,
        barrierDismissible: false,
        child: new Dialog(
            child: new Padding(
              padding: EdgeInsets.all(25.0),
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  new CircularProgressIndicator(),
                  new SizedBox(width: 20.0),
                  new Text(
                    "Verifying...",
                    style: new TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
            )),
      );*/

      setState(() {});

      //await compressImage(filePath);
    }
  }

  insertGroomingData(
      JCPGetterSetter store_data, String img_in, int deviation_flag) async {
    var dbHelper = DBHelper();
    int primary_key =
    await dbHelper.insertCoverageIn(store_data, img_in, deviation_flag);

    //if (primary_key > 0) showInSnackBar('Data saved successfully');

    var file = new File(filePath);

    //await compressImage(file, filePath);

    //await _uploadFile(file, img_in);
    //await Upload(file, img_in, filePath);

    //Navigator.of(context).pop("saved");
  }
}
