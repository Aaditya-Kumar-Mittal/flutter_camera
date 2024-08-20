// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/free_trained/pages/camera_main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final _cameras = await availableCameras();

  runApp(MyApp(
    cameras: _cameras,
  ));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraMainPage(
        cameras: cameras,
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_camera/hussain_mustafa_camera/pages/camera_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraPage(),
    );
  }
}
 */
