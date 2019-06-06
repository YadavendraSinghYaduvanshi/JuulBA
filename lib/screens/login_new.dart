import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';


class LoginNew extends StatefulWidget {
  @override
  _LoginNewState createState() => _LoginNewState();
}

class _LoginNewState extends State<LoginNew> {

  //static const platform = const MethodChannel('samples.flutter.io/battery');

  static final TextEditingController _uid = new TextEditingController();
  static final TextEditingController _psw = new TextEditingController();

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  static final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;

  var Manufacturer="";
  var DeviceModel="";
  var Andoid_Version="";
  var IMEI1="";
  var IMEI2="";

  // Initially password is obscure
  bool _obscureText = true;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  static BuildContext context_global;

  PackageInfo _packageInfo = new PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  PermissionGroup _permissionGroup;
  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  @override
  void initState() {
    super.initState();
    _loadPrefData();
    _initPackageInfo();
    fetchDeviceData();
    requestPermission(PermissionGroup.camera);
    //requestPermission(PermissionGroup.storage);
  }

  Future<Null> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> requestPermission(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
    await PermissionHandler().requestPermissions(permissions);

    setState(() {
      print(permissionRequestResult);
      _permissionStatus = permissionRequestResult[permission];
      print(_permissionStatus);
      if(permission==PermissionGroup.camera){
        requestPermission(PermissionGroup.location);
      }
      else if(permission==PermissionGroup.location){
        requestPermission(PermissionGroup.storage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context_global = context;

    String _password;

    return new LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return new Scaffold(
            appBar: new AppBar(
              title: new Text("Login"),
              backgroundColor: Colors.blue,
            ),
            body: new Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("assets/background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                child: new ConstrainedBox(
                  constraints: new BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: new IntrinsicHeight(
                    child: new Column(
                      children: <Widget>[
                        new Container(
                          margin: new EdgeInsets.symmetric(vertical: 20.0),
                          child: new Center(
                            child: new Image(
                              image: new AssetImage('assets/juul_logo.png'),
                              height: 150.0,
                              width: 150.0,
                            ),
                          ),
                        ),
                        new SizedBox(height: 24.0),
                        new Container(
                          margin: new EdgeInsets.symmetric(vertical: 10.0),
                          child: new Center(
                            child: new Form(
                                key: formKey,
                                child: new Card(
                                  child: new Container(
                                    padding: new EdgeInsets.all(15.0),
                                    child: new Column(
                                      children: <Widget>[
                                        new TextFormField(
                                          controller: _uid,
                                          decoration: new InputDecoration(
                                            labelText: 'User Id',
                                          ),
                                          validator: (val) => val.length < 1
                                              ? 'Please enter User Id.'
                                              : null,
                                          onSaved: (val) => _email = val,
                                        ),
                                        new Row(
                                          children: <Widget>[
                                            /* new TextFormField(
                                        controller: _psw,
                                        decoration:
                                        new InputDecoration(hintText: "Enter Password"),
                                        obscureText: true,
                                        validator: (val) => val.length < 1
                                            ? 'Please enter password.'
                                            : null,
                                        onSaved: (val) => _password = val,
                                      ),*/
                                            new Expanded(
                                              child: new TextFormField(
                                                controller: _psw,
                                                decoration: new InputDecoration(
                                                  suffixIcon: new Padding(
                                                    padding:
                                                        new EdgeInsetsDirectional
                                                            .only(start: 16.0),
                                                    child: new IconButton(
                                                        icon: new Icon(_obscureText
                                                            ? Icons.visibility
                                                            : Icons
                                                                .visibility_off),
                                                        onPressed: _toggle),
                                                  ),
                                                  labelText: 'Password',
                                                  /*icon: const Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15.0),
                                                    child: const Icon(
                                                        Icons.lock))*/
                                                ),
                                                validator: (val) => val.length <
                                                        1
                                                    ? 'Please enter password.'
                                                    : null,
                                                onSaved: (val) =>
                                                    _password = val,
                                                obscureText: _obscureText,
                                              ),
                                            ),
                                            /*new FlatButton(
                                            onPressed: _toggle,
                                            child: */ /*new Text(
                                                _obscureText ? "Show" : "Hide")*/ /*
                                            new Icon(_obscureText ? Icons.visibility : Icons.visibility_off))*/
                                          ],
                                        ),
                                        new Container(
                                          margin: new EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          child: new RaisedButton(
                                              child: new Text("Submit"),
                                              onPressed: () {
                                                //Navigator.of(context).pushNamed('/Second');
                                                _onLoading(context);
                                              }),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                          ),
                        ),
                        new SizedBox(height: 24.0),
                        new Container(
                          margin: new EdgeInsets.symmetric(vertical: 10.0),
                          child: new Center(
                            child: new Text("Version - " + _packageInfo.version, style: new TextStyle(fontSize: 18.0),),
                          ),
                        ),
                        new SizedBox(height: 15.0),
                        new Container(
                          margin: new EdgeInsets.symmetric(vertical: 10.0),
                          child: new Center(
                            child: new Text("(c) All rights reserved 2018"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
      },
    );
  }

/*  Future<Null> _installApk() async {
    try {
      final int result = await platform.invokeMethod('getApkInstall');
      //batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      //batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
  }*/

  void onSubmit() {
    print("Login with: " + _uid.text + " " + _psw.text);
  }

  void _onLoading(BuildContext context) {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();

      bool flag = true;
      if(userId!=null && userId!=""){
        if(userId!=_uid.text){
          flag = false;
        }
      }

      if(flag){
        // Email & password matched our validation rules
        // and are saved to _email and _password fields.
        showDialog<DialogDemoAction>(
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
        );

        new Future.delayed(new Duration(seconds: 3), () {
          /*Navigator.pop(context); //pop dialog
        Navigator.of(context).pushNamed('/MainPage');*/
          //getData();
          _fetchData();
        });
      }
      else{
        _AlertDialog('User Id is incorrect.', 0, "");
      }

    }
  }

  fetchDeviceData() async {
    DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
    DeviceModel = androidInfo.model;
    Manufacturer = androidInfo.manufacturer;
    Andoid_Version = androidInfo.version.sdkInt.toString();
  }

  var visit_date;
  static var userId;
  _loadPrefData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    visit_date = prefs.getString('CURRENTDATE');
    userId = prefs.getString('Userid_Main');
  }

  launchURL(String url) async {
    //const url = 'https://flutter.io';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _fetchData() async {
    print("Attempting to fetch...");

    try {
      final url =
          "http://lipromo.parinaam.in/Webservice/Liwebservice.svc/LoginDetaillatest";
      Map lMap = {
        "USER_ID": _uid.text,
        "PASSWORD": _psw.text,
        "IN_TIME": "13:42:01",
        "LATITUDE": "0.0",
        "LONGITUDE": "0.0",
        "APP_VERSION": "1.9",
        "ATT_MODE": "0",
        "Networkstatus": "0",
        "Manufacturer": Manufacturer,
        "Model": DeviceModel,
        "Andoid_Version": Andoid_Version,
        "IMEI1": "0",
        "IMEI2": "0"
      };

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
        var test1 = json.decode(test);

        //var res = test1[0]['Result'];
        var res = test1.toString();

        //if (res == "Faliure") {} else if (res == "Changed") {
        if (res.contains("Faliure")) {
        } else if (res.contains("Changed")) {
          Navigator.pop(context, DialogDemoAction.cancel);
          _neverSatisfied();
        } else {
          var data = test1['Result'][0];

          print(test1['Result'][0]['APP_PATH']);
          var apk_path = test1['Result'][0]['APP_PATH'];
          var app_version = test1['Result'][0]['APP_VERSION'];

          if(app_version == _packageInfo.buildNumber){
            _incrementCounter(data);
          }
          else{
            Navigator.pop(context, DialogDemoAction.cancel);
            _AlertDialog('New Update Available. Please install apk after download.', 1, apk_path);
          }

/*        var app_version = data['App_Version'];
        var app_path = data['App_Path'];
        var current_date = data['CURRENTDATE'];
        var notice_board = data['Notice'];*/
           //_installApk();
         // _incrementCounter(data);
          /*  Navigator.of(context_global).pop();
        Navigator.of(context_global).pushNamed('/MainPage');
*/
          //Route route = MaterialPageRoute(builder: (context_global) => Main_Activity());

        }
      });
    } catch (Exception) {
      Navigator.pop(context, DialogDemoAction.cancel);
      var dialog = await _AlertDialog('Network Error Please Try Again.', 0, "");
      if (dialog != null) {
       // Navigator.of(context).pop();
      }
    }
  }

  Future<String> _AlertDialog(String msg, int flag, String url_apk) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Alert'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(msg),
                //new Text('or Password'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Ok'),
              color: new Color(0xffEEEEEE),
              onPressed: () {
                if(flag==1){
                  launchURL(url_apk);
                }
                Navigator.of(context).pop("ok");
              },
            ),
          ],
        );
      },
    );
  }

  //set preference data
  Future _incrementCounter(var data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('Userid_Main', _uid.text);
    prefs.setString('Password', _psw.text);
    prefs.setString('CURRENTDATE', data['CURRENTDATE']);
    prefs.setString('Notice', data['Notice']);
    prefs.setString('Designation_Main', data['RIGHTNAME']);

    Navigator.of(context_global).pop();
    Navigator.pushReplacementNamed(context_global, '/MainPage');

    //_loadCounter();
  }

  Future<Null> _neverSatisfied() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Alert'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('Invalid User Id or Password'),
                //new Text('or Password'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Ok'),
              color: new Color(0xffEEEEEE),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //device info

  /*Future<Null> initPlatformState() async {
    Map<String, dynamic> deviceData;

    deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);

  *//*  try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }*//*

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }*/

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

/*  static final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};*/

  /*void _openLinkInGoogleChrome() {
    final AndroidIntent intent = new AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('https://flutter.io'),
        package: 'com.android.chrome');
    intent.launch();
  }*/
}

enum DialogDemoAction {
  cancel,
  discard,
  disagree,
  agree,
}


/*Permission*/
class MyPermissionClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                PermissionHandler().openAppSettings().then((bool hasOpened) =>
                    debugPrint('App Settings opened: ' + hasOpened.toString()));
              },
            )
          ],
        ),
        body: Center(
          child: ListView(
              children: PermissionGroup.values
                  .where((PermissionGroup permission) {
                /*if (Platform.isIOS) {
                  return permission != PermissionGroup.unknown &&
                      permission != PermissionGroup.sms &&
                      permission != PermissionGroup.storage;
                } else {*/
                  return permission != PermissionGroup.unknown &&
                      permission != PermissionGroup.mediaLibrary &&
                      permission != PermissionGroup.photos &&
                      permission != PermissionGroup.reminders;
                //}
              })
                  .map((PermissionGroup permission) =>
                  PermissionWidget(permission))
                  .toList()),
        ),
      ),
    );
  }
}

class PermissionWidget extends StatefulWidget {
  const PermissionWidget(this._permissionGroup);

  final PermissionGroup _permissionGroup;

  @override
  _PermissionState createState() => _PermissionState(_permissionGroup);
}

class _PermissionState extends State<PermissionWidget> {
  _PermissionState(this._permissionGroup);

  final PermissionGroup _permissionGroup;
  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() {
    final Future<PermissionStatus> statusFuture =
    PermissionHandler().checkPermissionStatus(_permissionGroup);

    statusFuture.then((PermissionStatus status) {
      setState(() {
        _permissionStatus = status;
      });
    });
  }

  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return Colors.red;
      case PermissionStatus.granted:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_permissionGroup.toString()),
      subtitle: Text(
        _permissionStatus.toString(),
        style: TextStyle(color: getPermissionColor()),
      ),
      trailing: IconButton(
          icon: const Icon(Icons.info),
          onPressed: () {
            checkServiceStatus(context, _permissionGroup);
          }),
      onTap: () {
        requestPermission(_permissionGroup);
      },
    );
  }

  void checkServiceStatus(BuildContext context, PermissionGroup permission) {
    PermissionHandler()
        .checkServiceStatus(permission)
        .then((ServiceStatus serviceStatus) {
      final SnackBar snackBar =
      SnackBar(content: Text(serviceStatus.toString()));

      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  Future<void> requestPermission(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
    await PermissionHandler().requestPermissions(permissions);

    setState(() {
      print(permissionRequestResult);
      _permissionStatus = permissionRequestResult[permission];
      print(_permissionStatus);
    });
  }
}