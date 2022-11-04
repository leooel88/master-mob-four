// ignore_for_file: library_private_types_in_public_api
import 'dart:ui';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import './assets/constants.dart' as constants;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawable',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class DrawingArea {
  Offset point;
  Paint areaPaint;

  DrawingArea({required this.point, required this.areaPaint});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final gradientColors = [
    constants.gradientViolet,
    constants.gradientRed,
    constants.gradientOrange,
  ];
  List<DrawingArea?> points = [];
  late Color selectedColor;
  late double strokeWidth;

  @override
  void initState() {
    super.initState;
    selectedColor = constants.black;
    strokeWidth = constants.lineWidthBasic;
  }

  void selectColor() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: constants.colorPickerDialogTitleText,
              content: SingleChildScrollView(
                  child: BlockPicker(
                      pickerColor: selectedColor,
                      onColorChanged: (color) {
                        setState(() {
                          selectedColor = color;
                        });
                      })),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: constants.colorPickerCloseButtonText)
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Stack(children: <Widget>[
      Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradientColors,
      ))),
      Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            Container(
                width: width * 0.80,
                height: height * 0.80,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(constants.smallRadius),
                    boxShadow: [constants.basicShadow]),
                child: GestureDetector(
                    onPanDown: (details) {
                      setState(() {
                        points.add(DrawingArea(
                            point: details.localPosition,
                            areaPaint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = selectedColor
                              ..strokeWidth = strokeWidth));
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        points.add(DrawingArea(
                            point: details.localPosition,
                            areaPaint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = selectedColor
                              ..strokeWidth = strokeWidth));
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        points.add(null);
                      });
                    },
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.all((constants.smallRadius)),
                      child: CustomPaint(
                        painter: MyCustomPainter(points: points),
                      ),
                    ))),
            const SizedBox(
              height: 20,
            ),
            Container(
                width: width * 0.80,
                decoration: const BoxDecoration(
                    color: constants.white,
                    borderRadius: BorderRadius.all(constants.smallRadius)),
                child: Row(children: <Widget>[
                  IconButton(
                      icon: constants.colorLens,
                      color: selectedColor,
                      onPressed: () {
                        selectColor();
                      }),
                  Expanded(
                      child: Slider(
                          min: constants.minLineWidth,
                          max: constants.maxLineWidth,
                          activeColor: selectedColor,
                          value: strokeWidth,
                          onChanged: (value) {
                            setState(() {
                              strokeWidth = value;
                            });
                          })),
                  IconButton(
                      icon: constants.layerClear,
                      onPressed: () {
                        setState(() {
                          points.clear();
                        });
                      }),
                ]))
          ]))
    ]));
  }
}

class MyCustomPainter extends CustomPainter {
  List<DrawingArea?> points;
  MyCustomPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = constants.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        Paint paint = points[i]!.areaPaint;
        canvas.drawLine(points[i]!.point, points[i + 1]!.point, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        Paint paint = points[i]!.areaPaint;
        canvas.drawPoints(PointMode.points, [points[i]!.point], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
