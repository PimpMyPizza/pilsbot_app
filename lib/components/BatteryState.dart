import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pilsbot/model/Common.dart';
import 'package:pilsbot/model/Communication.dart';

class BatteryState extends StatefulWidget {
  @override
  _BatteryStateState createState() => _BatteryStateState();
}

class _BatteryStateState extends State<BatteryState> {
  /// Battery percentage value
  int value = -1;
  /// Battery voltage text
  String text = '?%';
  /// Warning value. If the battery percentage is under this value,
  /// the battery icon will be shown in red with a warning sign
  final int warning = 20;
  /// Timer to get battery state every time period
  Timer timer;
  /// How often do we want to check the velocity?
  int period = 1; // seconds

  @override
  void initState(){
    super.initState();
    timer = Timer.periodic(Duration(seconds: period), (tim) async{
      var response = await restGet(restBatteryState);
      if(response[restBatteryState] != null) {
        if (response[restBatteryState] != value) {
          setState(() => value = response[restBatteryState]);
        }
      } else {
        setState(() => value = -1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    if (value >= 0 && value <= warning){
      color = Colors.redAccent;
      icon = Icons.battery_alert;
      text = value.toString()+'%';
    } else if (value > warning && value <= 100){
      color = Colors.blue;
      icon = Icons.battery_std;
      text = value.toString()+'%';
    } else {
      // Unknown battery percentage
      color = Colors.blue;
      icon = Icons.battery_unknown;
      text = '?%';
    }
    return Container(
      width: MediaQuery.of(context).size.width*0.2,
      height: MediaQuery.of(context).size.height*0.1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            size: 30.0,
            color: color,
          ),
          Text(text, style: TextStyle(color: color),),
        ],
      )
    );
  }
}
