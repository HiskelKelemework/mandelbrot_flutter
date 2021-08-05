import 'dart:ui';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Point {
  final Offset offset;
  final Color color;

  Point({required this.offset, this.color = Colors.black});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Point> points = [];

  bool rendering = false;

  double canvasWidth = 0, canvasHeight = 0;
  double x = -2.5, xsize = 4, y = -2.0, ysize = 0;

  double scaleFactor = 0.05;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () {
      computePoints();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    canvasWidth = screenWidth;
    canvasHeight = screenHeight * 0.8;

    ysize = xsize * canvasHeight / canvasWidth;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                width: canvasWidth,
                height: canvasHeight,
                child: CustomPaint(
                  painter: OpenPainter(points: points),
                ),
              ),
              Container(
                width: screenWidth * 0.8,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        x += 0.05;
                        computePoints();
                      },
                      icon: Icon(Icons.arrow_back_ios),
                    ),
                    IconButton(
                      onPressed: () {
                        x -= 0.05;
                        computePoints();
                      },
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                    IconButton(
                      onPressed: () {
                        y -= 0.05;
                        computePoints();
                      },
                      icon: Icon(Icons.keyboard_arrow_down),
                    ),
                    IconButton(
                      onPressed: () {
                        y += 0.05;
                        computePoints();
                      },
                      icon: Icon(Icons.keyboard_arrow_up),
                    ),
                    IconButton(
                      onPressed: () {
                        xsize -= scaleFactor;
                        ysize -= scaleFactor;
                        computePoints();
                      },
                      icon: Icon(Icons.zoom_in),
                    ),
                    IconButton(
                      onPressed: () {
                        xsize += scaleFactor;
                        ysize += scaleFactor;
                        computePoints();
                      },
                      icon: Icon(Icons.zoom_out),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double map(
    double num,
    double min_x,
    double max_x,
    double to_min_x,
    double to_max_x,
  ) {
    final scale_factor = (to_max_x - to_min_x) / (max_x - min_x);
    final main_diff = num - min_x;

    final scaled_x = to_min_x + scale_factor * main_diff;
    return scaled_x;
  }

  Offset computeNextInput(Offset current, Offset c) {
    // fc(z) = z^2 + c
    final newX = pow(current.dx, 2) - pow(current.dy, 2) + c.dx;
    final newY = (2 * current.dx * current.dy) + c.dy;

    return Offset(newX, newY);
  }

  void computePoints() {
    if (rendering) return;
    rendering = true;

    List<Point> shadedPoints = [];

    for (double ac = 0; ac < canvasWidth; ac++) {
      for (double bc = 0; bc < canvasHeight; bc++) {
        int counter = 0;

        var nextInput = Offset(0, 0);

        // scaled down versions of ac and bc to between -2 and 2
        final as = map(ac, 0, canvasWidth, x, x + xsize);
        final bs = map(bc, 0, canvasHeight, y, y + ysize);

        final coordinate = Offset(as, bs);

        while (counter < 50) {
          nextInput = computeNextInput(nextInput, coordinate);

          if (pow(nextInput.dx, 2) + pow(nextInput.dy, 2) > 4) {
            break;
          }

          counter++;
        }

        // didn't blow up to infinity.

        if (counter == 50) {
          shadedPoints.add(Point(offset: Offset(ac, bc)));
        }
      }
    }

    rendering = false;
    if (shadedPoints.isNotEmpty) {
      setState(() {
        points = shadedPoints;
      });
    }
  }
}

class OpenPainter extends CustomPainter {
  final List<Point> points;
  OpenPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.square //rounded points
      ..isAntiAlias = true
      ..strokeWidth = 3;

    final offsets = points.map((e) => e.offset).toList();
    //draw points on canvas
    canvas.drawPoints(PointMode.points, offsets, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
