import 'package:flutter/material.dart';
import './home.dart';

class Sound extends StatelessWidget {
  const Sound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          "Sound Level",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[900], // Set app bar color to match background
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),// Remove elevation
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(20.0, 150.0, 20.0, 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image(
                  image: AssetImage("assets/sound.png"),
                  width: 200,
                  height: 200,
                  alignment: Alignment.topCenter,
                ),
                SizedBox(height: 60),
                Text(
                  "25 dB(A)",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontFamily: "Poppins",
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  "Status: Normal",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontFamily: "Poppins",
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
