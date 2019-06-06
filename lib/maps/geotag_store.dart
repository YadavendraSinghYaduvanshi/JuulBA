import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:loreal_isp_supervisor_flutter/gettersetter/all_gettersetter.dart';
import 'package:camera/camera.dart';
import 'package:loreal_isp_supervisor_flutter/screens/camera_screen.dart';
import 'dart:async';
import 'package:loreal_isp_supervisor_flutter/database/dbhelper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as Im;

class GeoTagStore extends StatefulWidget {
  JCPGetterSetter store_data;

  // In the constructor, require a Todo
  GeoTagStore({Key key, @required this.store_data}) : super(key: key);

  @override
  _GeoTagStoreState createState() => _GeoTagStoreState();
}

class _GeoTagStoreState extends State<GeoTagStore> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isCompressed = false;

  @override
  void initState() {
    // TODO: implement initState
    _loadCounter();
    _getLocation();
    super.initState();
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
  }

  static final LatLng center = const LatLng(-33.86711, 151.1947171);
  double lat = 0.0;
  double lon = 0.0;

  GoogleMapController controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 1;
  String result_path;
  String visit_date, user_id;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onMarkerTapped(MarkerId markerId) {
    final Marker tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        if (markers.containsKey(selectedMarker)) {
          final Marker resetOld = markers[selectedMarker]
              .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          markers[selectedMarker] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        markers[markerId] = newMarker;
      });
    }
  }

  var currentLocation;

  void _add(Position position) {
    final int markerCount = markers.length;

    if (markerCount == 12) {
      return;
    }

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);
    print("locationLatitude: ${position.latitude}");
    print("locationLongitude: ${position.longitude}");
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        position.latitude,
        position.longitude,
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
        _onMarkerTapped(markerId);
      },
    );

    final LatLng latLng = LatLng(position.latitude, position.longitude);

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLng,
          tilt: 50.0,
          bearing: 45.0,
          zoom: 20.0,
        ),
      ),
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  void _remove() {
    setState(() {
      if (markers.containsKey(selectedMarker)) {
        markers.remove(selectedMarker);
      }
    });
  }

  void _changePosition() {
    final Marker marker = markers[selectedMarker];
    final LatLng current = marker.position;
    final Offset offset = Offset(
      center.latitude - current.latitude,
      center.longitude - current.longitude,
    );
    setState(() {
      markers[selectedMarker] = marker.copyWith(
        positionParam: LatLng(
          center.latitude + offset.dy,
          center.longitude + offset.dx,
        ),
      );
    });
  }

  _getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _add(position);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Geo Tag'),
            backgroundColor: Colors.green[700],
          ),
          body: new Container(
              color: Colors.white,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Expanded(
                      child: new GestureDetector(
                          child: new Card(
                            child: new Container(
                              child: Center(
                                child: GoogleMap(
                                  onMapCreated: _onMapCreated,
                                  initialCameraPosition: const CameraPosition(
                                    target: LatLng(28.7041, 77.1025),
                                    zoom: 11.0,
                                  ),
                                  // TODO(iskakaushik): Remove this when collection literals makes it to stable.
                                  // https://github.com/flutter/flutter/issues/28312
                                  // ignore: prefer_collection_literals
                                  markers: Set<Marker>.of(markers.values),
                                ),
                              ),
                            ),
                          ),
                          onTap: () {})),
                  new Container(
                    margin: new EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 5.0),
                    child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          new RawMaterialButton(
                            onPressed: () {
                              opencamera(1, "GeoTagImage");
                            },
                            child: result_path != null && filePath != null
                                ? new Icon(
                                    Icons.camera,
                                    color: Colors.green,
                                    size: 30.0,
                                  )
                                : new Icon(
                                    Icons.camera,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                            shape: new CircleBorder(),
                            elevation: 2.0,
                            fillColor: Colors.white,
                            padding: const EdgeInsets.all(15.0),
                          ),
                          new RawMaterialButton(
                            onPressed: () {
                              if (result_path != null) {
                                //insertStoreData(widget.store_data, result_path);
                                _geoTagData(widget.store_data, result_path);
                                //compressImage(null, filePath);
                                //Navigator.of(context).pop();
                              } else {
                                showInSnackBar('Please click image');
                              }
                            },
                            child: new Icon(
                              Icons.save,
                              color: Colors.blue,
                              size: 30.0,
                            ),
                            shape: new CircleBorder(),
                            elevation: 2.0,
                            fillColor: Colors.white,
                            padding: const EdgeInsets.all(15.0),
                          ),
                        ]),
                  )
                ],
              ))),
      /*floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() {
                //_counter++;
              }),
          tooltip: 'Increment Counter',
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,*/
    );
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

  _geoTagData(JCPGetterSetter jcp, String path) async {
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
                  "Uploading",
                  style: new TextStyle(fontSize: 18.0),
                ),
              ],
            ),
          )),
    );

    String upload_status, int_time_img, out_time_img;


      upload_status = "I";

      int_time_img = path;

      out_time_img = "";

    print("Attempting to fetch... ");

    try {
      final url =
          "http://lipromo.parinaam.in/Webservice/Liwebservice.svc/UploadStoreCoverageSup";

      Map lMap = {
        "STORE_CD": jcp.STORE_CD,
        "USER_ID": user_id,
        "VISIT_DATE": visit_date,
        "IN_TIME": "00:00:00",
        "OUT_TIME": "00:00:00",
        "LATITUDE": "0.0",
        "LONGITUDE": "0.0",
        "APP_VERSION": "1",
        "REASON_ID": "0",
        "REASON_REMARK": "",
        "IMAGE_URL": int_time_img,
        "UPLOAD_STATUS": upload_status,
        "OUT_TIME_IMAGE": out_time_img
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
        if (test.toString().contains("Success")) {
          insertStoreGeoTagData(jcp, path, 0);
        } else {}
        //var test1 = json.decode(test);
      });
    } catch (Exception) {
      //Navigator.pop(context, DialogDemoAction.cancel);
      var dialog = await _AlertDialog();
      if (dialog != null) {
        // Navigator.of(context).pop();
      }
    }
  }

  insertStoreGeoTagData(
      JCPGetterSetter store_data, String img_in, int deviation_flag) async {
    var dbHelper = DBHelper();
    int primary_key =
    await dbHelper.insertCoverageIn(store_data, img_in, deviation_flag);

    //if (primary_key > 0) showInSnackBar('Data saved successfully');

    var file = new File(filePath);

    //await compressImage(file, filePath);

    //await _uploadFile(file, img_in);
    await Upload(file, img_in, filePath);

    //Navigator.of(context).pop("saved");
  }

  Upload(File imageFile, String img_name, String file_path) async {

    if(!isCompressed){
      await compressImage(file_path);
    }

    String uploadURL =
        "http://lipromo.parinaam.in/LoralMerchandising.asmx/Uploadimages";
    Dio dio = new Dio();
    FormData formdata = new FormData(); // just like JS
    formdata.add("file", new UploadFileInfo(imageFile, img_name));
    formdata.add("Foldername", "StoreImageSup");
    dio.post(uploadURL,
        data: formdata,
        options: Options(
            method: 'POST',
            responseType: ResponseType.PLAIN // or ResponseType.json
        ))
        .then((response) =>
        showUploadSuccess('Result' + response.toString(), imageFile))
        .catchError((error) =>  _AlertDialog());

    //String uploadURL = "http://lipromo.parinaam.in/Webservice/Liwebservice.svc/GetImages";


    /* var uri = Uri.parse("http://pub.dartlang.org/packages/create");
    var request = new http.MultipartRequest("POST", url);
  */ /* request.fields['user'] = 'nweiz@google.com';
    request.files.add(new http.MultipartFile.f
    request.files.add(new http.MultipartFile.fromFile(
        'package',
        new File('build/package.tar.gz'),
        contentType: new MediaType('application', 'x-tar'));
        request.send().then((response) {
      if (response.statusCode == 200) print("Uploaded!");
    });*/
  }

  Future compressImage(String file_path) async {

    File imageFile = new File(file_path);

    Im.Image image = Im.decodeImage(imageFile.readAsBytesSync());
    Im.Image smallerImage = Im.copyResize(image, width:600); // choose the size here, it will maintain aspect ratio

    var compressedImage = new File('$file_path')..writeAsBytesSync(Im.encodeJpg(smallerImage, quality: 90));
    isCompressed = true;
  }

  Future<String> _AlertDialog() async {
    Navigator.pop(context, DialogDemoAction.cancel);
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Alert'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('Network Error Please Try Again.'),
                //new Text('or Password'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Ok'),
              color: new Color(0xffEEEEEE),
              onPressed: () {
                Navigator.of(context).pop("ok");
              },
            ),
          ],
        );
      },
    );
  }

  void showUploadSuccess(String message, File file) {
    Navigator.pop(context, DialogDemoAction.cancel);
    if (message.contains("Success")) {
      file.delete();
    }
    _showUploadResult();
  }

  Future<Null> _showUploadResult() async {
    showDialog<DialogDemoAction>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Alert'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('Data uploaded successfully'),
                //new Text('or Password'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Ok'),
              color: new Color(0xffEEEEEE),
              onPressed: () {
                Navigator.pop(context, DialogDemoAction.cancel);
                Navigator.of(context).pop("saved");
              },
            ),
          ],
        );
      },
    );
  }
}

enum DialogDemoAction {
  cancel,
  discard,
  disagree,
  agree,
}

class RoundedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 60.0,
        width: 250.0,
        child: Material(
          shape: StadiumBorder(),
          textStyle: Theme.of(context).textTheme.button,
          elevation: 6.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  elevation: 0.0,
                  color: Colors.white,
                  shape: new RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(50))),
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.add,
                          color: Colors.green,
                          size: 30.0,
                        ),
                        Text("New Message")
                      ],
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
              Expanded(
                child: RaisedButton(
                  elevation: 0.0,
                  color: Colors.white,
                  shape: new RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.horizontal(right: Radius.circular(50))),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.more_vert,
                          color: Colors.green,
                          size: 30.0,
                        ),
                        Text("More")
                      ],
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(),
    );
  }
}
