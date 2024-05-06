class Fares{
  double valueKm = 0.0;
  double valueMin = 0.0;

  Fares({required this.valueKm,required this.valueMin});

}

class FareInfo{

  double traveledKm = 0.0;
  Duration traveledTime = Duration(seconds: 0);

  FareInfo({required this.traveledKm,required this.traveledTime});

}
