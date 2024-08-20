import 'dart:io';

import 'package:camera/camera.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:media_scanner/media_scanner.dart';

class CameraMainPage extends StatefulWidget {
  const CameraMainPage({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  State<CameraMainPage> createState() => _CameraMainPageState();
}

class _CameraMainPageState extends State<CameraMainPage> {
  late CameraController cameraController;
  late Future<void> cameraValue;
  bool isFlashOn = false;
  bool isRearCamera = true;
  List<File> imageList = [];

  void startCamera(int cameraIndex) {
    cameraController = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.high,
    );
    cameraValue = cameraController.initialize();
  }

  Future<File> saveImage(XFile image) async {
    final download = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('$download/$fileName');

    try {
      await file.writeAsBytes(await image.readAsBytes());
    } catch (_) {}

    return file;
  }

  void takePicture() async {
    XFile? picture;

    if (cameraController.value.isTakingPicture ||
        !cameraController.value.isInitialized) {
      return;
    }
    if (isFlashOn == false) {
      await cameraController.setFlashMode(FlashMode.off);
    } else {
      await cameraController.setFlashMode(FlashMode.torch);
    }

    picture = await cameraController.takePicture();

    if (cameraController.value.flashMode == FlashMode.torch) {
      setState(() {
        cameraController.setFlashMode(FlashMode.off);
      });
    }

    final file = await saveImage(picture);

    setState(() {
      imageList.add(file);
    });

    MediaScanner.loadMedia(path: file.path);
  }

  @override
  void initState() {
    //0 means start using the Front Camera
    //1 means start using the Rear Camera
    startCamera(1);
    super.initState();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  height: size.height,
                  width: size.width,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: CameraPreview(cameraController),
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isFlashOn = !isFlashOn;
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(50, 0, 0, 0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: isFlashOn
                              ? const Icon(
                                  Icons.flash_on_sharp,
                                  color: Colors.yellow,
                                  size: 30,
                                )
                              : const Icon(
                                  Icons.flash_off_sharp,
                                  color: Colors.white,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                    const Gap(10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isRearCamera = !isRearCamera;
                        });
                        isRearCamera ? startCamera(1) : startCamera(0);
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(50, 0, 0, 0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: isRearCamera
                              ? const Icon(
                                  Icons.camera_rear_sharp,
                                  color: Colors.blue,
                                  size: 30,
                                )
                              : const Icon(
                                  Icons.camera_front_sharp,
                                  color: Colors.red,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 7, bottom: 75),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image(
                                height: 100,
                                width: 100,
                                opacity: const AlwaysStoppedAnimation(07),
                                image: FileImage(File(imageList[index].path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                        itemCount: imageList.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: takePicture,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 3, color: Colors.white),
          ),
          child: const Center(
            child: Icon(
              Icons.camera_alt_outlined,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
