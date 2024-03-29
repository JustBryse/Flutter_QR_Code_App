import 'package:ceg4912_project/Models/receipt_item.dart';

class Receipt {
  int _id = -1;
  DateTime _dateTime = DateTime.now();
  double _cost = 0.00;
  int _mid = -1;
  int _cid = -1;
  List<ReceiptItem> _receiptItems = [];

  Receipt.empty();

  Receipt() {
    _id = -1;
    _dateTime = DateTime.now();
    _cost = 0.00;
    _mid = -1;
    _cid = -1;
    _receiptItems = [];
  }
  //Blockchain Initializer;
  Receipt.BCParams(int id, DateTime dateTime, double cost, int mid, int cid) {
    _id = id;
    _dateTime = dateTime;
    _cost = cost;
    _mid = mid;
    _cid = cid;
  }

  Receipt.all(int id, DateTime dateTime, double cost, int mid, int cid,
      List<ReceiptItem> receiptItems) {
    _id = id;
    _dateTime = dateTime;
    _cost = cost;
    _mid = mid;
    _cid = cid;
    _receiptItems = receiptItems;
  }

  Receipt.no_items(int id, DateTime dateTime, double cost, int mId, int cId) {
    _id = id;
    _dateTime = dateTime;
    _cost = cost;
    _mid = mId;
    _cid = cId;
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

  List<ReceiptItem> getReceiptItems() {
    return _receiptItems;
  }
}
