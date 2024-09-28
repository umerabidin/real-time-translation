import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_labeling_ai/face_detection.dart';
import 'package:image_labeling_ai/translation/language_trans.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ImageLabelling(),
    );
  }
}

class ImageLabelling extends StatefulWidget {
  const ImageLabelling({Key? key}) : super(key: key);

  @override
  State<ImageLabelling> createState() => _ImageLabellingState();
}

class _ImageLabellingState extends State<ImageLabelling> {
  late InputImage _inputImage;
  File? _pickedImage;
  static final ImageLabelerOptions _options =
      ImageLabelerOptions(confidenceThreshold: 0.8);

  final imageLabeler = ImageLabeler(options: _options);

  final ImagePicker _imagePicker = ImagePicker();

  String text = "";

  pickImageFromGallery() async {
    XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    setState(() {
      _pickedImage = File(image.path);
    });
    _inputImage = InputImage.fromFile(_pickedImage!);
    identifyImage(_inputImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Labelling"),
      ),
      body: Container(
        height: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          if (_pickedImage != null)
            Image.file(
              _pickedImage!,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: 300,
              color: Colors.black,
              width: double.infinity,
            ),
          Expanded(
            child: Container(),
          ),
          Text(text, style: TextStyle(fontSize: 20)),
          Expanded(
            child: Container(),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Pick Image"),
              onPressed: () {
                pickImageFromGallery();
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Face detection"),
              onPressed: () {
                Navigator.push(
    context,
    MaterialPageRoute(builder: (context) =>  FaceDetectorView()),
  );
              },
            ),
          ),
          CustomCard(
                          'On-device Translation', LanguageTranslatorView()),
        ]),
      ),
    );
  }

  void identifyImage(InputImage inputImage) async {
    final List<ImageLabel> image = await imageLabeler.processImage(inputImage);
    

    if (image.isEmpty) {
      setState(() {
        text = "Cannot identify the image";
      });
      return;
    }

    for (ImageLabel img in image) {
      setState(() {
        text = "Label : ${img.label}\nConfidence : ${img.confidence}";
      });
    }
    imageLabeler.close();
  }
}

class CustomCard extends StatelessWidget {
  final String _label;
  final Widget _viewPage;
  final bool featureCompleted;

  const CustomCard(this._label, this._viewPage, {this.featureCompleted = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: Theme.of(context).primaryColor,
        title: Text(
          _label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          if (!featureCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    const Text('This feature has not been implemented yet')));
          } else {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => _viewPage));
          }
        },
      ),
    );
  }
}