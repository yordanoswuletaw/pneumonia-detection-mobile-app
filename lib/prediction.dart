import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Prediction extends StatefulWidget {
  const Prediction({super.key});

  @override
  State<Prediction> createState() => _PredictionState();
}

class _PredictionState extends State<Prediction> {
  File? _image;
  bool _loading = false;
  List? _output;

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: 'assets/pnuemonia_lite.tflite',
      labels: 'assets/labels.txt',
    );
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _loading = true;
      _image = File(image.path);
    });
    classifyImage(_image!);
  }

  Future<void> takeImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    setState(() {
      _loading = true;
      _image = File(image.path);
    });
    classifyImage(_image!);
  }

  Future<void> classifyImage(File image) async {
    final output = await Tflite.runModelOnImage(
      path: image.path,
    );

    setState(() {
      _loading = false;
      _output = output;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _loading
                    ? const LinearProgressIndicator(
                        minHeight: 10,
                      )
                    : _image == null
                        ? const Text('No image selected.')
                        : Container(
                            width: MediaQuery.of(context).size.width - 50,
                            height: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(
                                  _image!,
                                ),
                              ),
                            ),
                          ),
                const SizedBox(height: 32),
                _loading
                    ? const CircularProgressIndicator()
                    : _output != null
                        ? Text(
                            '${_output![0]['label']}',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.indigo),
                          )
                        : const Text(''),
                const SizedBox(height: 32),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Expanded(flex: 1, child: Text('')),
                  ElevatedButton(
                    onPressed: () {
                      takeImage();
                    },
                    child: const Icon(Icons.camera),
                  ),
                  const Expanded(flex: 2, child: Text('')),
                  ElevatedButton(
                    onPressed: () {
                      pickImage();
                    },
                    child: const Icon(Icons.image),
                  ),
                  const Expanded(flex: 1, child: Text('')),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
