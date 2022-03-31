class Movesense{
  int timestamp;
  int mobileTimestamp;
  double mAcc; //Accelerometer value, X Y and Z summarized.

  Movesense(this.timestamp, this.mAcc, this.mobileTimestamp);

  void setTime(int time)
  {
    timestamp = time;
  }
  void setForce(double acc)
  {
    mAcc = acc;
  }
  void setMobileTime(int time){
    mobileTimestamp = time;
  }
  int getTime()
  {
    return timestamp;
  }
  double getForce()
  {
    return mAcc;
  }
  int getMobileTime(){
    return mobileTimestamp;
  }
}
