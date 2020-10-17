import 'package:flutter/material.dart';
import 'package:roslib/roslib.dart';


class PartyLight extends StatefulWidget {
  Ros ros;
  PartyLight({@required  this.ros});

  @override
  _PartyLightState createState() => _PartyLightState();
}

class _PartyLightState extends State<PartyLight> {
  /// Are the lights on?
  /// 1=yes, 0=no, -1=no info
  int isLightOn;
  /// ROS topic to subscribe to
  Topic sub;
  Topic pub;

  @override
  void initState(){
    sub = Topic(ros: widget.ros, name: '/lighting/party', type: "std_msgs/Bool", reconnectOnClose: true, queueLength: 10, queueSize: 10);
    pub = Topic(ros: widget.ros, name: '/app/cmd/lighting/party', type: "std_msgs/Bool", reconnectOnClose: true, queueLength: 10, queueSize: 10);
    super.initState();
    isLightOn = -1;
    initConnection();
  }

  void initConnection() async {
    await sub.subscribe();
    setState(() {});
  }

  void destroyConnection() async {
    await sub.unsubscribe();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: sub.subscription,
        builder: (context, snapshot) {
          Color colorFill;
          Color colorIcon;
          isLightOn = -1;
          if(snapshot.hasData){
            var value = Map<String, dynamic>.from(Map<String, dynamic>.from(snapshot.data)['msg'])['data'];
            if(value == true){
              isLightOn = 1;
            } else {
              isLightOn = 0;
            }
          }
          if(isLightOn==1){
            colorFill = Colors.blue;
            colorIcon = Colors.orange;
          } else if(isLightOn==0){
            colorFill = Colors.blue;
            colorIcon = Colors.black54;
          } else { // unknown status
            colorFill = Colors.grey;
            colorIcon = Colors.black12;
          }
          return Container(
              width: MediaQuery.of(context).size.width*0.065,
              height: MediaQuery.of(context).size.height*0.1,
              margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height*0.01,
                  horizontal: MediaQuery.of(context).size.width*0.01
              ),
              child: RawMaterialButton(
                onPressed: () async {
                  if(isLightOn==1){
                    pub.publish({'data': false});
                  } else {
                    pub.publish({'data': true});
                  }
                },
                elevation: 2.0,
                fillColor: colorFill,
                child: Icon(
                  Icons.mood,
                  size: 30.0,
                  color: colorIcon,
                ),
                shape: CircleBorder(),
              )
          );
        }
    );
  }
}
