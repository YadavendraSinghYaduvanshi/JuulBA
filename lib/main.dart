import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'screens/download_data.dart';
import 'screens/reports.dart';
import 'screens/attendance_report.dart';
import 'screens/login_new.dart';
import 'screens/splash_screen.dart';
import 'screens/mark_attendance.dart';
import 'screens/promoter_list.dart';
import 'screens/attendance.dart';
import 'screens/camera_screen.dart';
import 'screens/store_list.dart';
import 'screens/attendance_screens/attendance_defaulters_with_5days_absent.dart';
import 'screens/attendance_screens/attendance_defaulters_with_3days_absent.dart';
import 'screens/attendance_screens/attendance_tgt_vs_ach_planned_logins.dart';
import 'screens/promoter_performance/promoter_performance.dart';
import 'screens/promoter_performance/oqad_over_all.dart';
import 'screens/promoter_performance/oqad_selling_skills.dart';
import 'screens/promoter_performance/oqad_product_knowledge.dart';
import 'screens/self_visitor_login/self_visitor_login.dart';
import 'screens/manning_leaves_absenteeism/manning_leave_absenteeism.dart';
import 'screens/manning_leaves_absenteeism/daywise_time_spent.dart';
import 'screens/manning_leaves_absenteeism/average_time_spent.dart';
import 'screens/manning_leaves_absenteeism/storewise_man_days.dart';
import 'screens/manning_leaves_absenteeism/promoter_wise_present_days.dart';
import 'screens/self_visitor_login/visitor_login.dart';
import 'screens/self_visitor_login/no_of_days_worked.dart';
import 'screens/self_visitor_login/visitor_time_spent.dart';
import 'screens/supervisor_list.dart';
import 'maps/geotag_store.dart';

import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'dart:async';

//void main() => runApp(new MyApp());

void main() async {
  bool isInDebugMode = false;

  FlutterError.onError = (FlutterErrorDetails details) {
    if (isInDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Crashlytics.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  await FlutterCrashlytics().initialize();

  runZoned<Future<Null>>(() async {
    runApp(MyApp());
  }, onError: (error, stackTrace) async {
    // Whenever an error occurs, call the `reportCrash` function. This will send
    // Dart errors to our dev console or Crashlytics depending on the environment.
    await FlutterCrashlytics().reportCrash(error, stackTrace, forceCrash: false);
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Loreal ISP SUP',
      routes: <String, WidgetBuilder>{
        '/MainPage': (BuildContext context)=>new Main_Activity(),
        '/Download': (BuildContext context)=>new DownloadData(),
        '/Reports': (BuildContext context)=>new ReportList(),
        '/Attendance': (BuildContext context)=>new Attendance(),
        '/Login': (BuildContext context)=>new LoginNew(),
        '/MarkAttendance': (BuildContext context)=>new MarAttendance(),
        '/PromoterList': (BuildContext context)=>new PromoterList(),
        '/AttendanceList': (BuildContext context)=>new AttendanceList(),
        '/AttendanceDefaulter5Days': (BuildContext context)=>new AttendanceDefaulter5Days(),
        '/AttendanceDefaulter3Days': (BuildContext context)=>new AttendanceDefaulter3Days(),
        '/AttendanceTgtVsAchPlannedLogins': (BuildContext context)=>new AttendanceTgtVsAchPlannedLogins(),
        //'/StoreList': (BuildContext context)=>new StoreList(),
        '/PerformanceList': (BuildContext context)=>new PerformanceList(),
        '/OQADOverAll': (BuildContext context)=>new OQADOverAll(),
        '/OQADSellingSkills': (BuildContext context)=>new OQADSellingSkills(),
        '/OQADProductKnowledge': (BuildContext context)=>new OQADProductKnowledge(),
        '/SelfVisitorLogin': (BuildContext context)=>new SelfVisitorLogin(),
        '/ManningLeaveList': (BuildContext context)=>new ManningLeaveList(),
        '/DaywiseTimeSpent': (BuildContext context)=>new DaywiseTimeSpent(),
        '/AverageTimeSpent': (BuildContext context)=>new AverageTimeSpent(),
        '/StorewiseManDays': (BuildContext context)=>new StorewiseManDays(),
        '/PromoterWisePresentDays': (BuildContext context)=>new PromoterWisePresentDays(),
        '/VisitorLogin': (BuildContext context)=>new VisitorLogin(),
        '/NoDaysWorked': (BuildContext context)=>new NoDaysWorked(),
        '/VisitorTimeSpent': (BuildContext context)=>new VisitorTimeSpent(),
        '/SupervisorList': (BuildContext context)=>new SupervisorList(),
        '/geotagstore': (BuildContext context)=>new GeoTagStore(),
        //'/NonWorking': (BuildContext context)=>new NonWorking(),
        //'/CameraApp': (BuildContext context)=>new CameraExampleHome(),
      },
      home: new SplashScreen(),
      //home: new LoginNew(),
      //home: new Login(),
    );
  }
}
