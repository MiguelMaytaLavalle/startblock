import 'dart:async';
import 'livedata.dart';

class Data{
  int _time = 0;
  double _force = 0;

  Data(int time, double force);

  void setTime(int time)
  {
    _time = time;
  }
  void setForce(double force)
  {
    _force = force;
  }
  getTime()
  {
    return _time;
  }
  getForce()
  {
    return _force;
  }
}
