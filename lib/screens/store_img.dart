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
import 'dart:math' as Math;


class StoreImage extends StatefulWidget {
  JCPGetterSetter store_data;
  int deviation_flag;

  // In the constructor, require a Todo
  StoreImage({Key key, @required this.store_data, this.deviation_flag})
      : super(key: key);

  @override
  _StoreImageState createState() => _StoreImageState();
}

class _StoreImageState extends State<StoreImage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String visit_date, user_id;
  String result_path;
  bool isCompressed = false;

  @override
  void initState() {
    // TODO: implement initState
    _loadCounter(widget.store_data);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text("Store Image"),
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
                        widget.store_data.UPLOAD_STATUS == "N"
                            ? "Click Store Checkin Image"
                            : "Click Store Checkout Image",
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
                          String img_type =
                              widget.store_data.UPLOAD_STATUS == "N"
                                  ? "Checkin_Image"
                                  : "Checkout_Image";
                          opencamera(widget.store_data.STORE_CD, img_type);
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
                          _checkinData(widget.store_data, result_path,
                              widget.deviation_flag);
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

  //--------------------------

  Future compressImage(String file_path) async {

    File imageFile = new File(file_path);

    Im.Image image = Im.decodeImage(imageFile.readAsBytesSync());
    Im.Image smallerImage = Im.copyResize(image, width:600); // choose the size here, it will maintain aspect ratio

    var compressedImage = new File('$file_path')..writeAsBytesSync(Im.encodeJpg(smallerImage, quality: 90));
    isCompressed = true;
  }

  Upload(File imageFile, String img_name, String file_path) async {
/*    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();*/

    /* var uploadURL = "http://lipromo.parinaam.in/Webservice/Liwebservice.svc/GetImages";
    var uri = Uri.parse(uploadURL);

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, length, filename: img_name,);//basename(imageFile.path));

    //contentType: new MediaType('image', 'png'));

    new MultipartBody.Builder()
        .setType(MediaType.parse("multipart/form-data"))
        .addFormDataPart("file", finalFile.getName(), requestFile)
        .addFormDataPart("Foldername", foldername)
        .build();*/
    //request.fields['Foldername'] = 'StoreImageSup';
    /* request.fields['file'] = img_name;
    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });*/

    /*   var dio = new Dio();
    dio.options.baseUrl = "http://lipromo.parinaam.in/Webservice/Liwebservice.svc/GetImages";

    FormData formData = new FormData.from({
      */ /*"name": "wendux",
      "age": 25,*/ /*
      "file": new UploadFileInfo(imageFile, img_name),
      // In PHP the key must endwith "[]", ("files[]")
     */ /* "files": [
        new UploadFileInfo(new File("./example/upload.txt"), "upload.txt"),
        new UploadFileInfo(new File("./example/upload.txt"), "upload.txt")
      ]*/ /*
    });
    Response response1 = await dio.post("/token", data: formData);
    print(response1.data);
*/
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

  //--------------------------

  CoverageGettersetter coverage;

  //Loading counter value on start
  Future _loadCounter(JCPGetterSetter store_data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    SharedPreferences.getInstance().then((SharedPreferences sp) {
      prefs = sp;
      visit_date = prefs.getString('CURRENTDATE');
      user_id = prefs.getString('Userid_Main');
      // will be null if never previously saved
    });
    visit_date = prefs.getString('CURRENTDATE');
    user_id = prefs.getString('Userid');

    if (store_data.UPLOAD_STATUS == "I") {
      var dbHelper = DBHelper();
      coverage = await dbHelper.getCoverage(visit_date, store_data.STORE_CD);
    }
  }

  _createJCP(JCPGetterSetter jcp, String img_in) async {
    try {
      final url =
          "http://lipromo.parinaam.in/Webservice/Liwebservice.svc/UploadJorneyPlanSup";
      Map lMap = {
        "STORE_CD": jcp.STORE_CD,
        "USER_ID": user_id,
        "VISIT_DATE": visit_date,
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
          var file = new File(filePath);

          //await _uploadFile(file, img_in);
          Upload(file, img_in, filePath);
        } else {}
        //var test1 = json.decode(test);
      });
    } catch (Exception) {

      var dialog = await _AlertDialog();
      if (dialog != null) {
        // Navigator.of(context).pop();
      }
    }
  }

  _checkinData(JCPGetterSetter jcp, String path, int deviation_flag) async {
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

    if (jcp.UPLOAD_STATUS == "I") {
      upload_status = "U";

      if (coverage != null) {
        int_time_img = coverage.STORE_IMG_IN;
      } else {
        int_time_img = "";
      }

      out_time_img = path;
    } else {
      upload_status = "I";

      int_time_img = path;

      out_time_img = "";
    }

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
          if (jcp.UPLOAD_STATUS == "N") {
            insertStoreData(jcp, path, deviation_flag);
          } else {
            deleteCoverageData(jcp, path, deviation_flag);
          }
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

  insertStoreData(
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

  deleteCoverageData(
      JCPGetterSetter store_data, String img_in, int deviation_flag) async {
    var dbHelper = DBHelper();
    int primary_key = await dbHelper.deleteCoverageSpecific(
        store_data.STORE_CD, deviation_flag);

    var file = new File(filePath);

    //await compressImage(file, filePath);

    if(deviation_flag==0){

      await Upload(file, img_in, filePath);
    }
    else{
      //in case of deviation store create JCP
      _createJCP(store_data, img_in);
    }


    //Navigator.of(context).pop("saved");

    //if (primary_key > 0) showInSnackBar('Data saved successfully');
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  void showUploadSuccess(String message, File file) {
    Navigator.pop(context, DialogDemoAction.cancel);
    if (message.contains("Success")) {
      file.delete();
    }
    _showUploadResult();
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

  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');

  String _fileContents;
  String kTestString = "Hello world!";

 /* Future<Null> _uploadFile(File file, String file_name) async {
    *//* final Directory systemTempDir = Directory.systemTemp;
    final File file = await new File('${systemTempDir.path}/foo.txt').create();
   file.writeAsString(kTestString);
    assert(await file.readAsString() == kTestString);
    final String rand = "${new Random().nextInt(10000)}";*//*
    final StorageReference ref =
        FirebaseStorage.instance.ref().child(file_name);
    final StorageUploadTask uploadTask = ref.put(
        file, StorageMetadata(contentLanguage: "en", contentType: "image/jpg"));

    final Uri downloadUrl = (await uploadTask.future).downloadUrl;
    final http.Response downloadData = await http.get(downloadUrl);
    setState(() {
      _fileContents = downloadData.body;
    });

    if (downloadData.reasonPhrase == "OK") {
      file.delete();
    }
    Navigator.pop(context, DialogDemoAction.cancel);
    Navigator.of(context).pop("saved");
  }*/

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
