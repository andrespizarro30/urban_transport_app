class TripsHistoryModel{
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? FareAmount;
  String? driverName;
  String? car_details;

  TripsHistoryModel({
    this.time,
    this.originAddress,
    this.destinationAddress,
    this.status,
    this.FareAmount,
    this.driverName,
    this.car_details

  });

  TripsHistoryModel.fromMap(Map map){
    time = map["time"].toString();
    originAddress = map["originAddress"].toString();
    destinationAddress = map["destinationAddress"].toString();
    status = map["status"].toString();
    FareAmount = map["FareAmount"].toString();
    driverName = map["driverName"].toString();
    car_details = map["car_details"].toString();

  }

}

class TripsHistoryModelD{
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? FareAmount;
  String? userName;
  String? userPhone;

  TripsHistoryModelD({
    this.time,
    this.originAddress,
    this.destinationAddress,
    this.status,
    this.FareAmount,
    this.userName,
    this.userPhone

  });

  TripsHistoryModelD.fromMap(Map map){
    time = map["time"].toString();
    originAddress = map["originAddress"].toString();
    destinationAddress = map["destinationAddress"].toString();
    status = map["status"].toString();
    FareAmount = map["FareAmount"].toString();
    userName = map["userName"].toString();
    userPhone = map["userPhone"].toString();

  }

}