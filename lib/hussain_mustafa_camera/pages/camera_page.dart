// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_print

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  //Variable to keep track of the cameras available
  List<CameraDescription> cameras = [];

  //Optional CameraController because we might have a controller and we might not have a controller
  CameraController? cameraController;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    //If the app lifecycle does change
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      //reconstruct the camera setup once again
      _setupCameraController();
    }
  }

  @override
  void initState() {
    super.initState();
    _setupCameraController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return const Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //For ios won't work, Stimulated Feed Appears only in Android
            // Display the camera preview
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.80,
                child: CameraPreview(cameraController!)),
            // Button to take a picture and save it to the gallery
            IconButton(
              onPressed: () async {
                // Take a picture using the camera controller
                XFile picture = await cameraController!.takePicture();

                // Save the picture to the gallery using the Gal package
                Gal.putImage(
                  picture.path,
                );
              },
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.black,
                size: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to setup the camera controller
  Future<void> _setupCameraController() async {
    List<CameraDescription> _cameras = await availableCameras();

    //Checks that cameras are on the device and the camera list is not empty
    if (_cameras.isNotEmpty) {
      //If we have cameras on the device, call the setState and set the cameras to camera list
      setState(() {
        cameras = _cameras;

        //Once we have the camera list ready, create the camera controller
        //Camera Description - Basically a camera form the list of cameras available
        //Resolution Preset - How high is going to be the resolution for the actual camera feed
        cameraController =
            CameraController(_cameras.last, ResolutionPreset.high);

        //For a back camera, reinitialize the camera controller with another camera from the list eg. _cameras.last
        //cameraController = CameraController(_cameras.last, ResolutionPreset.high);
      });

      //Once camera controller is create, initialize it.
      cameraController?.initialize().then((_) {
        //Error handling step - if user puts the app in back state or exists the application before initialization
        // If the widget is not mounted, return early to avoid errors
        if (!mounted) {
          return;
        }
        //setState rebuilds the widget tree for the camera UI
        setState(() {});
      }).catchError((Object error) {
        print(error);
      });
    }
  }
}
