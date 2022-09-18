class Receipt {
  int _id = -1;
  DateTime _dateTime = DateTime.now();
  double _cost = 0.00;
  int _mid = -1;
  int _cid = -1;

  Receipt.empty();
  Receipt.all(int id, DateTime dateTime, double cost, int mid, int cid) {
    _id = id;
    _dateTime = dateTime;
    _cost = cost;
    _mid = mid;
    _cid = cid;
  }

  int getId() {
    return _id;
  }

  DateTime getDateTime() {
    return _dateTime;
  }

  double getCost() {
    return _cost;
  }

  int getMerchantId() {
    return _mid;
  }

  int getCustomerId() {
    return _cid;
  }
}