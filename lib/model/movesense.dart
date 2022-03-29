class Movesense{
  int timestamp;
  double mAcc; //Accelerometer value, X Y and Z summarized.
  Movesense(this.timestamp, this.mAcc);
  void setTime(int time)
  {
    timestamp = time;
  }
  void setForce(double acc)
  {
    mAcc = acc;
  }
  int getTime()
  {
    return timestamp;
  }
  double getForce()
  {
    return mAcc;
  }
}
