import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Training Data',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Training Data'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  double posX = 0, posY = 300;
  var _flag = 0;

  @override
  Widget build(BuildContext context) {
    final gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();
    if (_flag == 1) {
      postData();
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          StreamBuilder<GyroscopeEvent>(
              stream: SensorsPlatform.instance.gyroscopeEvents,
              builder: (context, gyroscope) {
                if (gyroscope.hasData) {
                  posX = posX + (gyroscope.data!.y * 10);
                  posY = posY + (gyroscope.data!.x * 10);
                }
                return Transform.translate(
                  offset: Offset(posX, posY),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.red,
                  ),
                );
              }),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 100.0, horizontal: 24.0),
            child: Column(
              children: [
                "User Accelerometer values : $userAccelerometer".text.make(),
                SizedBox(
                  height: 20,
                ),
                "Gyroscope values : $gyroscope".text.make(),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 75),
                      child: ElevatedButton(
                          onPressed: () {
                            _flag = 1;
                            print("Started.");
                            setState(() {});
                            // postData();
                          },
                          child: "Start".text.make()),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          _flag = 0;
                          print("Stopped.");
                          setState(() {});
                        },
                        child: "Stop".text.make()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  postData() async {
    sleep(Duration(seconds: 3));
    try {
      var gyroscope =
          _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
      var userAccelerometer = _userAccelerometerValues
          ?.map((double v) => v.toStringAsFixed(1))
          .toList();
      // print(gyroscope);
      // print(userAccelerometer);

      var response = await http.post(
          Uri.parse("https://shielded-escarpment-21691.herokuapp.com/"),
          body: {
            "ax": userAccelerometer![0].toString(),
            "ay": userAccelerometer[1].toString(),
            "az": userAccelerometer[2].toString(),
            "gx": gyroscope![0].toString(),
            "gy": gyroscope[1].toString(),
            "gz": gyroscope[2].toString(),
          });
      print(response.body);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    super.initState();
  }
}
