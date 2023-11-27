import 'package:flutter/material.dart';

import 'face_detector_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DemoPage());
}

class DemoPage extends StatelessWidget {
  const DemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: Home());
  }
}

class Home extends StatelessWidget {
  final bool featureCompleted;
  const Home({Key? key, this.featureCompleted = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Card(
          elevation: 5,
          child: ListTile(
            title: const Text("Hi ML."),
            onTap: () {
              if (!featureCompleted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content:  Text('This feature has not been implemented yet')));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FaceDetectorView()));
              }
            },
          ),
        ),
      )),
    );
  }
}
