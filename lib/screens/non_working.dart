import 'package:flutter/material.dart';
import 'package:loreal_isp_supervisor_flutter/gettersetter/all_gettersetter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loreal_isp_supervisor_flutter/database/dbhelper.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;

class NonWorking extends StatefulWidget {
  JCPGetterSetter store_data;

  // In the constructor, require a Todo
  NonWorking({Key key, @required this.store_data}) : super(key: key);

  @override
  _NonWorkingState createState() => _NonWorkingState();
}

class Reason {
  const Reason(this.name);

  final String name;
}

class _NonWorkingState extends State<NonWorking> {
  NonWorkingReasonGetterSetter selectedReason;
  bool isCompressed = false;
  /*List<Reason> reasonList = <Reason>[
    const Reason('Present'),
    const Reason('Leave'),
    const Reason('Holiday')
  ];*/
  NonWorkingReasonGetterSetter reason_selected;

  /*var reason_selected = "";
  int selected_reason_cd =0;*/

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String visit_date, user_id;
  String result_path;

  @override
  void initState() {
    // TODO: implement initState
    _loadCounter(widget.store_data);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          if (selectedReason == null) {

            showInSnackBar("Please select a reason");
          } else if (selectedReason.IMAGE_ALLOW==1 && result_path == null) {
            showInSnackBar('Please click image');
          } else {
            //insertStoreData(widget.store_data, result_path);

              submit();
            //Navigator.of(context).pop();
          }
        },
        child: new Icon(Icons.cloud_upload),
      ),
      appBar: new AppBar(
        title: new Text(
          "Non Working",
        ),
      ),
      body: new Container(
        child: new Column(
          children: <Widget>[
            new Center(
              child: new Container(
                margin: EdgeInsets.all(20.0),
                child: new Text("Select a reason",
                    style: TextStyle(
                      fontSize: 20.0,
                    )),
              ),
            ),
            new Container(
                margin: EdgeInsets.all(30.0),
                child: new Center(
                  child: new DropdownButton<NonWorkingReasonGetterSetter>(
                    hint: new Text(
                      "Select",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    value: selectedReason,
                    onChanged: (NonWorkingReasonGetterSetter newValue) {
                      setState(() {
                        selectedReason = newValue;
                      });
                    },
                    items:
                        reasonList.map((NonWorkingReasonGetterSetter reason) {
                      return new DropdownMenuItem<NonWorkingReasonGetterSetter>(
                        value: reason,
                        child: new Text(
                          reason.REASON,
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )),
            selectedReason != null && selectedReason.IMAGE_ALLOW == 1
                ? new GestureDetector(
              onTap:() {
                opencamera(widget.store_data.STORE_CD, "NonWorkingImg");
              } ,
              child: result_path!=null?new Image(
                image: new AssetImage('assets/camera_icon_tick.png'),
                height: 100.0,
                width: 100.0,
              ):new Image(
                image: new AssetImage('assets/camera_icon.png'),
                height: 100.0,
                width: 100.0,
              ),
            )
                : new Text(""),
          ],
        ),
      ),
    );
  }

  void showInSnackBar(String message) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  submit() async{
    if(selectedReason.ENTRY_ALLOW == 1){
      await _checkinData(widget.store_data, result_path);
    }
    else{
      for(int i=0; i<store_list.length;i++){
       await _checkinData(store_list[i], "");
      }

      Navigator.pop(context, DialogDemoAction.cancel);
      Navigator.of(context).pop();
    }
  }


  _checkinData(JCPGetterSetter jcp, String path) async {
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

    upload_status = "U";

    int_time_img = path;
    if(int_time_img==null){
      int_time_img = "";
    }

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
        "REASON_ID": selectedReason.REASON_CD,
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
          InsertCoverageData(jcp, path);
        } else {}
        //var test1 = json.decode(test);
      });
    } catch (Exception) {
      Navigator.pop(context, DialogDemoAction.cancel);
      var dialog = await _AlertDialog();
      if (dialog != null) {
        // Navigator.of(context).pop();
      }
    }
  }

  Future<String> _AlertDialog() async {
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

  InsertCoverageData(JCPGetterSetter store_data, String img_in) async {
    var dbHelper = DBHelper();
    int primary_key =
    await dbHelper.deleteCoverageSpecific(store_data.STORE_CD, 0);

    if(img_in!=null && img_in!=""){
      var file = new File(filePath);
      //await _uploadFile(file, img_in);
      await Upload(file, img_in);
    }
    else{
      Navigator.pop(context, DialogDemoAction.cancel);
      Navigator.of(context).pop();
    }

    //Navigator.of(context).pop("saved");

    //if (primary_key > 0) showInSnackBar('Data saved successfully');
  }

  Upload(File imageFile, String img_name) async {
    if(!isCompressed){
      await compressImage(filePath);
    }
    //String uploadURL = "http://lipromo.parinaam.in/Webservice/Liwebservice.svc/GetImages";
    String uploadURL = "http://lipromo.parinaam.in/LoralMerchandising.asmx/Uploadimages";
    Dio dio = new Dio();
    FormData formdata = new FormData(); // just like JS
    formdata.add("file", new UploadFileInfo(imageFile, img_name));
    formdata.add("Foldername", "StoreImageSup");
    dio.post(uploadURL, data: formdata, options: Options(
        method: 'POST',
        responseType: ResponseType.PLAIN // or ResponseType.json
    ))
        .then((response) =>
        showUploadSuccess('Result'+response.toString(), imageFile))
        .catchError((error) => print(error));

  }

  void showUploadSuccess(String message, File file){
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
      setState(() {});

      //await compressImage(filePath);
    }
  }

  Future<Null> compressImage(String file_path) async {

    File imageFile = new File(file_path);

    img.Image image = img.decodeImage(imageFile.readAsBytesSync());
    img.Image smallerImage = img.copyResize(image, width:600); // choose the size here, it will maintain aspect ratio

    var compressedImage = new File('$file_path')..writeAsBytesSync(img.encodeJpg(smallerImage, quality: 90));
    isCompressed = true;
  }

  String _fileContents;
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

  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');

  CoverageGettersetter coverage;
  List<NonWorkingReasonGetterSetter> reasonList = new List();

  List<JCPGetterSetter> store_list;

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

    var dbHelper = DBHelper();
    if (store_data.UPLOAD_STATUS == "I") {
      coverage = await dbHelper.getCoverage(visit_date, store_data.STORE_CD);
    }

    store_list = await dbHelper.getJCPList(visit_date, 0);

    reasonList = await fetchData();
    if (reasonList.length > 0) {
      setState(() {});
    }
  }

  Future<List<NonWorkingReasonGetterSetter>> fetchData() async {
    //var t1 = await _openDb();
    var dbHelper = DBHelper();

    bool upload_flag = false;

    for(int i=0; i<store_list.length;i++){
      if(store_list[i].UPLOAD_STATUS=="U"){
        upload_flag = true;
        break;
      }
    }

    List<NonWorkingReasonGetterSetter> reason_list =  await dbHelper.getNonWorkingReasonList(upload_flag);
    //List<JCPGetterSetter> store_list = await dbHelper.getJCPList(visit_date);


    return reason_list;
  }
}

enum DialogDemoAction {
  cancel,
  discard,
  disagree,
  agree,
}