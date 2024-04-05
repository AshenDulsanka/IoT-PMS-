import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class Current extends StatefulWidget {
  const Current({Key? key}) : super(key: key);

  @override
  _CurrentState createState() => _CurrentState();
}

class _CurrentState extends State<Current> {
  final databaseRef = FirebaseDatabase.instance.ref().child('sensors');
  String _current = '';
  String? _deviceToken;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  List<FlSpot> currentData = [];
  int index = 0;

  @override
  void initState() {
    super.initState();

    _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    _messaging.getToken().then((token) {
      print('Device token: $token');
      _deviceToken = token;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message: ${message.notification?.body}');
    });

    databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final currentLevel = data['current'] as int? ?? 0;
        final currentPercentage = ((currentLevel / 10) * 100).toStringAsFixed(2);
        _sendNotificationWithoutWidgetCheck(currentPercentage);
        setState(() {
          _current = currentPercentage;
          currentData.add(FlSpot(index.toDouble(), double.parse(currentPercentage)));
          index++;
        });
      }
    });
  }

  Future<void> _sendNotificationWithoutWidgetCheck(String currentPercentage) async {
    final currentValue = double.tryParse(currentPercentage) ?? 0.0;
    if (currentValue < 30.0) {
      await _sendNotification("Warning! Very Low Current");
    } else if (currentValue < 70.0) {
      await _sendNotification("Load is Low");
    }
  }

  Future<void> _sendNotification(String body) async {
    final String serverKey =
        'AAAAMr10t2E:APA91bGIjp_V3WynamWaN0OitufgFjaGbPE5WDOcM9Vi_zGW91-oiGMkkv6vu5736vTXXfuJ1AflJr3N7PH-8qYXdJ3xbDmiBeFo83GKRE-EpYlh64Hmt7K1Vzy9hgY1Al3LdchObdR1';
    final String? deviceToken = _deviceToken;

    if (deviceToken == null) {
      print('Device token is not available');
      return;
    }

    final Map<String, dynamic> notificationData = {
      'notification': {
        'title': 'Current Status',
        'body': body,
      },
      'to': deviceToken,
    };

    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(notificationData),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPercentage = double.tryParse(_current) ?? 0.0;
    String status;
    if (currentPercentage < 30.0) {
      status = "Status: Warning! Very Low Current";
    } else if (currentPercentage < 70.0) {
      status = "Status: Load is Low";
    } else {
      status = "Status: Normal";
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          "Current/ Load",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(20.0, 120.0, 20.0, 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image(
                  image: AssetImage("assets/current_load.png"),
                  width: 200,
                  height: 200,
                  alignment: Alignment.topCenter,
                ),
                SizedBox(height: 40),
                Text(
                  _current + "%",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontFamily: "Poppins",
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontFamily: "Poppins",
                  ),
                ),
                SizedBox(height: 70),
                Container(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: currentData,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (value, color, data, index) =>
                                FlDotCirclePainter(
                                  radius: 5,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ],
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}