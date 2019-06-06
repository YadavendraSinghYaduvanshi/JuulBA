import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:loreal_isp_supervisor_flutter/gettersetter/all_gettersetter.dart';

class CameraExampleHome extends StatefulWidget {
  List<CameraDescription> cameras;

  //int store_cd;
  int store_cd;
  String user_id;
  String image_type;

  // In the constructor, require a Todo
  CameraExampleHome(
      {Key key,
      @required this.cameras,
      this.store_cd,
      this.user_id,
      this.image_type})
      : super(key: key);

  @override
  _CameraExampleHomeState createState() {
    return new _CameraExampleHomeState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw new ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraExampleHomeState extends State<CameraExampleHome> {
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    //checkPermission();
    super.initState();
  }

  /*requestPermission(Permission permission) async {
    var res = await SimplePermissions.requestPermission(permission);
    print("permission request result is " + res.toString());
    if (res == PermissionStatus.denied) {
      Navigator.pop(context);
    }
  }

  checkPermission() async {
    //check for Camera
    bool res = await SimplePermissions.checkPermission(Permission.Camera);
    if (!res) {
      requestPermission(Permission.Camera);
    }

    //check for WriteExternalStorage
    res = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);

    if (!res) {
      requestPermission(Permission.WriteExternalStorage);
    }

    print("permission is " + res.toString());

    res = await SimplePermissions.checkPermission(Permission.Camera);
    if (!res) {
      Navigator.pop(context);
    }

    res = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);
    if (!res) {
      Navigator.pop(context);
    }
    print("permission is " + res.toString());
  }*/

  //tells which camera front or rear is to be open
  int index = 0;
  bool isfirst_time = true;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      /*appBar: new AppBar(
        title: const Text('Camera example'),
      ),*/
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new Container(
              child: new Padding(
                padding: const EdgeInsets.all(1.0),
                child: new Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
              decoration: new BoxDecoration(
                color: Colors.black,
                border: new Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          new Row(
            children: <Widget>[
              new Expanded(child: _captureControlRowWidget()),
              new Padding(
                padding: const EdgeInsets.all(5.0),
                child: _cameraTogglesRowWidget(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      /* return const Text(
        'Tap a camera',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );*/
    } else {
      return new AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: new CameraPreview(controller),
      );
    }
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return new Expanded(
      child: new Align(
        alignment: Alignment.centerRight,
        child: videoController == null && imagePath == null
            ? null
            : new SizedBox(
                child: (videoController == null)
                    ? new Image.file(new File(imagePath))
                    : new Container(
                        child: new Center(
                          child: new AspectRatio(
                              aspectRatio: videoController.value.size != null
                                  ? videoController.value.aspectRatio
                                  : 1.0,
                              child: new VideoPlayer(videoController)),
                        ),
                        decoration: new BoxDecoration(
                            border: new Border.all(color: Colors.pink)),
                      ),
                width: 64.0,
                height: 64.0,
              ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        new IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  !controller.value.isRecordingVideo
              ? onTakePictureButtonPressed
              : null,
        ),
        /*new IconButton(
          icon: const Icon(Icons.videocam),
          color: Colors.blue,
          onPressed: controller != null &&
              controller.value.isInitialized &&
              !controller.value.isRecordingVideo
              ? onVideoRecordButtonPressed
              : null,
        ),
         new IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          onPressed: controller != null &&
              controller.value.isInitialized &&
              controller.value.isRecordingVideo
              ? onStopButtonPressed
              : null,
        )*/
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];
    Widget cam_change;

    if (widget.cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      /*for (CameraDescription cameraDescription in widget.cameras) {
       toggles.add(
          new SizedBox(
            width: 90.0,
            child: new RadioListTile<CameraDescription>(
              title:
              new Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: controller != null && controller.value.isRecordingVideo
                  ? null
                  : onNewCameraSelected,
            ),
          ),
        );

      }*/
      if (isfirst_time) {
        isfirst_time = false;
        onNewCameraSelected(widget.cameras[index]);
      }

      cam_change = new GestureDetector(
        child: new Icon(getCameraLensIcon(widget.cameras[index].lensDirection)),
        onTap: () {
          int temp_index = index + 1;
          if (temp_index == widget.cameras.length) {
            index = 0;
          } else {
            index = temp_index;
          }
          setState(() {});
          onNewCameraSelected(widget.cameras[index]);
        },
      );
    }

    return cam_change;
  }

  String timestamp() =>
      "Store_" +
      widget.image_type +
      "-" +
      widget.user_id +
      "-Store_CD-" +
      widget.store_cd.toString() +
      "_" +
      new DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    //set image quality low
    controller = new CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (filePath != null) {
          //showInSnackBar('Picture saved to $filePath');
          //_showCapturedImage();
          _openAddEntryDialog();
        }
        //Navigator.of(context).pop();
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      //if (filePath != null) showInSnackBar('Saving video to $filePath');
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recorded to: $videoPath');
    });
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    await _startVideoPlayer();
  }

  Future<void> _startVideoPlayer() async {
    final VideoPlayerController vcontroller =
        new VideoPlayerController.file(new File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imagePath = null;
        videoController = vcontroller;
      });
    }
    await vcontroller.play();
  }

  //this image file name is returned
  String img_file_name;

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getExternalStorageDirectory();
    final String dirPath = '${extDir.path}/Pictures/Loreal_ISP_SUP_IMG';
    await new Directory(dirPath).create(recursive: true);

    img_file_name = '${timestamp()}.jpg';

    final String filePath = '$dirPath/' + img_file_name;

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

/*  Future<Null> opencamera() async {
    // Fetch the available cameras before initializing the app.
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }
    Navigator.of(context).pushNamed('/CameraApp');
  }*/
  Future<Null> _showCapturedImage() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          contentPadding: EdgeInsets.all(0.0),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Image(image: FileImage(new File(imagePath)))
                //new Text('or Password'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Ok'),
              color: new Color(0xffEEEEEE),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/Reports', (Route<dynamic> route) => false);
              },
            ),
            new FlatButton(
              child: new Text('Cancel'),
              color: new Color(0xffEEEEEE),
              onPressed: () {
                Navigator.of(context).pop();
                onNewCameraSelected(widget.cameras[index]);
              },
            ),
          ],
        );
      },
    );
  }

  Future _openAddEntryDialog() async {
    var img_path =
        await Navigator.of(context).push(new MaterialPageRoute<String>(
            builder: (BuildContext context) {
              return new MyDialog(
                path: imagePath,
              );
            },
            fullscreenDialog: true));

    if (img_path != null) {
      if (img_path != "Cancel") Navigator.of(context).pop(img_file_name);
    }
  }
}

class MyDialog extends StatefulWidget {
  String path;

  MyDialog({Key key, @required this.path}) : super(key: key);

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
        child: new Center(
          child: new Column(
            children: <Widget>[
              new Image(image: FileImage(new File(widget.path))),
              new Row(
                children: <Widget>[
                  new Expanded(
                    child: new FlatButton(
                      child: new Text('Ok'),
                      color: new Color(0xffEEEEEE),
                      onPressed: () {
                        Navigator.of(context).pop(widget.path);

                        //Navigator.of(context).pop(new ImageGettersetter(widget.path));

                        /* Navigator.of(context).pushNamedAndRemoveUntil(
                            '/Reports', (Route<dynamic> route) => false);*/
                      },
                    ),
                  ),
                  new Expanded(
                    child: new FlatButton(
                      child: new Text('Cancel'),
                      color: new Color(0xffEEEEEE),
                      onPressed: () {
                        new File(widget.path).delete();
                        Navigator.of(context).pop("Cancel");
                        // onNewCameraSelected(widget.cameras[index]);
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}

/*
Future<Null> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  runApp(new CameraApp());
}*/
