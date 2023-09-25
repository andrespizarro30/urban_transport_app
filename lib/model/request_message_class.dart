class PushMessageServiceRequestData {
  String? rideRequestId;
  String? id;
  String? clickAction;
  String? status;

  PushMessageServiceRequestData({this.rideRequestId, this.id, this.clickAction, this.status});

  PushMessageServiceRequestData.fromJson(Map<String, dynamic> json) {
    rideRequestId = json['rideRequestId'];
    id = json['id'];
    clickAction = json['click_action'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rideRequestId'] = this.rideRequestId;
    data['id'] = this.id;
    data['click_action'] = this.clickAction;
    data['status'] = this.status;
    return data;
  }
}