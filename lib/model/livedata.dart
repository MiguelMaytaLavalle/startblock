class LiveData {

  double force = 0;

  LiveData({
    required this.force
}); //Constructor

  Map<String, dynamic> toJson() => {
    'force': force
  };

  factory LiveData.fromJson(Map<String, dynamic> json) => LiveData(
    force: json['force']
  );

}
