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
  int getTime()
  {
    return timestamp;
  }
  double getForce()
  {
    return mForce;
  }
}
