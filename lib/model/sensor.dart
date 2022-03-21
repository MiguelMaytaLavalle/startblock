import 'dart:async';
import 'livedata.dart';

class Data{
  int timestamp;
  double mForce;

  Data(this.timestamp, this.mForce);


  void setTime(int time)
  {
    timestamp = time;
  }
  void setForce(double force)
  {
    mForce = force;
  }
  double getTime()
  {
    return timestamp.toDouble();
  }
  double getForce()
  {
    return mForce;
  }


}
