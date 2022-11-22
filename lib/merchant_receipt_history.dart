import 'package:ceg4912_project/Models/receipt.dart';
import 'package:ceg4912_project/Support/session.dart';
import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/Support/utility.dart';
import 'package:ceg4912_project/merchant_filter.dart';
import 'package:ceg4912_project/merchant_home.dart';
import 'package:flutter/material.dart';

import 'Models/item.dart';
import 'Models/receipt_item.dart';

var merchantName = "Amazon";

class MerchantReceiptHistoryPageRoute extends StatelessWidget {
  const MerchantReceiptHistoryPageRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MerchantReceiptHistoryPage());
  }
}

// widget for filter and sort
class Filter extends StatefulWidget {
  final List<String> choices;
  const Filter({Key? key, required this.choices}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FilterState();
}

//Class for the filter functionality
class _FilterState extends State<Filter> {
  // contains the choices
  final List<String> _selectedFilterOptions = [];

  // triggered when a checkbox is selected/unselected
  void _selected(String option, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedFilterOptions.add(option);
      } else {
        _selectedFilterOptions.remove(option);
      }
    });
  }

  // called when user submits their choices
  void _submit() {
    Navigator.pop(context, _selectedFilterOptions);
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Options'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.choices
              .map(
                (choice) => CheckboxListTile(
                  value: _selectedFilterOptions.contains(choice),
                  title: Text(choice),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isChecked) => _selected(choice, isChecked!),
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
        TextButton(onPressed: _cancel, child: const Text('Cancel'))
      ],
    );
  }
}

class MerchantReceiptHistoryPage extends StatefulWidget {
  const MerchantReceiptHistoryPage({Key? key}) : super(key: key);

  @override
  _ReceiptHistoryState createState() => _ReceiptHistoryState();
}

//Class for the receipt history state
class _ReceiptHistoryState extends State<MerchantReceiptHistoryPage> {
  // list of selected filters
  List<String> _choices = [];

  //New
  // list of receipts
  List<Receipt> receipts = <Receipt>[];
  // stores the UI widgets that represent merchant's receipts
  List<Widget> receiptWidgets = <Widget>[];
  // keeps track of which receipt widgets are expanded in the UI
  List<bool> receiptExpandedStateSet = <bool>[];
  //Stores all customers
  List<int> customerIds = <int>[];

  // the color of event messages that are displayed to the user
  Color eventMessageColor = Colors.white;
  // the message that is displayed to the user to inform them of events
  String eventMessage = "";

  // initially get the merchant's receipts upon loading the receipt page
  @override
  void initState() {
    super.initState();
    _getReceipts();
  }

  Future<void> loadMerchantFilterPage() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MerchantFilter(),
      ),
    );
    customerIds = result;
  }

  // generates widgets for all of the current merchant's business receipt
  void _getReceipts() async {
    int mId = Session.getSessionUser().getId();
    // hardcoded cid for now

    var conn = await Queries.getConnection();
    //var mReceipts = await Queries.getMerchantReceipts(conn, mId, 1);
    var mReceipts = [];

    //Get list of receipt ids
    var receiptIds = await Queries.getMerchantReceiptIds(conn, mId, customerIds);

    //Loops through receipt Ids
    for(int receiptId in receiptIds) {
      //Get list of receipt ids for current id

      var receiptItemIds = await Queries.getReceiptItemIds(conn, receiptId);
      print("ReceiptItemIDs");
      print(receiptItemIds);
      if (receiptItemIds == null) {
        setState(() {
          eventMessage = "Receipt Retrieval Failed: Receipt has no receipt items.";
          eventMessageColor = Colors.red;
        });
        // clears the event message after 2 seconds have passed
        clearEventMessage(2000);
        return;
      }
      //Add receipt item ids to the list
      var receipt_master = [];
      for(int receiptItemId in receiptItemIds) {
        receipt_master.add(receiptItemId);
      }

      var itemTest = await Queries.getItemByReceiptId(conn, 28);
      //print("printing item");
      //print(itemTest);


      var itemList = [];
      //Go through receipt items, per receipt, create each item, save in list
      for(int receiptItemId in receipt_master){
         var item = await Queries.getItemByReceiptId(conn, receiptItemId);
         print("legit item:");
         print(item);

         if (item == null) {
           setState(() {
             eventMessage = "Receipt Retrieval Failed: Receipt has no receipt items.";
             eventMessageColor = Colors.red;
           });
           // clears the event message after 2 seconds have passed
           clearEventMessage(2000);
           return;
         }
         itemList.add(item);
      }

      //print("test");
      //print(itemList);
      //create receipt items
      var receiptItems = <ReceiptItem>[];
      for(Item item in itemList) {
        receiptItems.add(ReceiptItem.create(item));
      }

      //get dateTime, Cost, mid, cid
      DateTime dateTime = await Queries.getReceiptDateTime(conn, receiptId);
      var cost = await Queries.getReceiptCost(conn, receiptId);
      var cid = await Queries.getReceiptCid(conn, receiptId);
      int cidparam = int.parse(cid);

      //create the receipt with the current receipt id
      mReceipts.add(Receipt.all(receiptId, dateTime, cost, mId, cidparam, receiptItems));
    }

    // if the query went wrong then it would return null
    if (mReceipts == null) {
      setState(() {
        eventMessage = "Receipt Retrieval Failed.";
        eventMessageColor = Colors.red;
      });

      // clears the event message after 2 seconds have passed
      clearEventMessage(2000);
      return;
    }

    // upon refresh, reset the lists that keeps track of the receipts that are showing on the UI
    receipts.clear();
    receiptWidgets.clear();
    receiptExpandedStateSet.clear();

    for (int i = 0; i < mReceipts.length; i++) {
      receipts.add(mReceipts[i]);
      receiptExpandedStateSet.add(false);

      setState(() {
        receiptWidgets.add(getReceiptWidget(i, false));
      });
    }
  }

  // clears the event message after some time has passed
  void clearEventMessage(int delay) {
    Future.delayed(Duration(milliseconds: delay), () {
      setState(() {
        eventMessage = "";
        eventMessageColor = Colors.white;
      });
    });
  }

  // expands the full details of an item to the UI
  void expandReceipt(int receiptIndex) {
    bool expandedState =
        !receiptExpandedStateSet[receiptIndex]; // invert the state
    receiptExpandedStateSet[receiptIndex] = expandedState;
    setState(() {
      receiptWidgets[receiptIndex] =
          getReceiptWidget(receiptIndex, expandedState);
    });
  }

  // returns a widget that represents a receipt
  Widget getReceiptWidget(int i, bool isExpanded) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        color: const Color.fromARGB(255, 46, 73, 107),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    "Receipt ID: " + receipts[i].getId().toString(),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 20,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => {expandReceipt(i)},
                  icon: const Icon(
                    Icons.description,
                    color: Colors.blue,
                  ),
                )
              ],
            ),
            if (isExpanded)
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              "COST: " + receipts[i].getCost().toString(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              "CUSTOMER ID: " +
                                  receipts[i].getCustomerId().toString(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              "DATE: " + receipts[i].getDateTime().toString(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              "MERCHANT ID: " +
                                  receipts[i].getMerchantId().toString(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  //End New

  void _showFilter() async {
    // create list of options
    // dynamically fetch from database... hardcoded for now
    final List<String> _options = [
      'Receipt Number',
      'Total Price',
      'Customer Name'
    ];

    //Store the users selection in results
    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Filter(choices: _options);
      },
    );

    // Update the user interface
    if (results != null) {
      setState(() {
        _choices = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Receipt History'),
        backgroundColor: Utility.getBackGroundColor(),
        leading: IconButton(
            alignment: Alignment.centerLeft,
            onPressed:() => Navigator.push(
                context,MaterialPageRoute(
                builder: (_) => const MerchantHomePage(
                )
            )),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Divider(
              height:30,
            ),
              ElevatedButton(
                  onPressed: loadMerchantFilterPage,
                  child: const Text('Filter By Customer')),
              ElevatedButton(
                onPressed: _getReceipts,
                child: const Text('Search')),

              Column(children: receiptWidgets),

            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  eventMessage,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: eventMessageColor,
                    fontSize: 20,
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
