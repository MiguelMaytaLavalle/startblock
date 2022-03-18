import 'dart:async';
import 'livedata.dart';

class Data{
  int timestamp = 0;
  double mForce = 0;

  Data(int time, double force, {timestamp, mForce});

  void setTime(int time)
  {
    timestamp = time;
  }
  void setForce(double force)
  {
    mForce = force;
  }
  getTime()
  {
    return timestamp;
  }
  getForce()
  {
    return mForce;
  }


}
