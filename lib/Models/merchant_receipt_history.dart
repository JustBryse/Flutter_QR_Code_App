import 'package:ceg4912_project/Models/receipt.dart';
import 'package:ceg4912_project/Support/session.dart';
import 'package:ceg4912_project/Support/queries.dart';
import 'package:flutter/material.dart';

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

  // called when user sumbits their choices
  void _submit() {
    Navigator.pop(context, _selectedFilterOptions);
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context){
    return AlertDialog(
      title: const Text('Select Options'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.choices
              .map((choice) => CheckboxListTile(
              value: _selectedFilterOptions.contains(choice),
              title: Text(choice),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (isChecked) => _selected(choice, isChecked!),
          ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _submit,
            child: const Text('Submit'),
        ),
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel')
        )
      ],
    );
  }
}

class MerchantReceiptHistoryPage extends StatefulWidget {
  const MerchantReceiptHistoryPage({Key? key}) : super(key: key);

  @override
  _ReceiptHistoryState createState() => _ReceiptHistoryState();
}

class _ReceiptHistoryState extends State<MerchantReceiptHistoryPage> {
  // list of selected filters
  List<String> _choices = [];

  //New
  // list of receipts
  List<Receipt> receipts = <Receipt>[];
  // stores the UI widgets that represent merchant's items
  List<Widget> receiptWidgets = <Widget>[];
  // keeps track of which item widgets are expanded in the UI
  List<bool> receiptExpandedStateSet = <bool>[];

  // the color of event messages that are displayed to the user
  Color eventMessageColor = Colors.white;
  // the message that is displayed to the user to inform them of events
  String eventMessage = "";

  // initially get the merchant's business items upon loading the item page
  @override
  void initState() {
    super.initState();
    _getReceipts();
  }

  // generates widgets for all of the current merchant's business items
  void _getReceipts() async {
    int mId = Session.getSessionUser().getId();
    var conn = await Queries.getConnection();
    var mReceipts = await Queries.getMerchantReceipts(conn, mId);

    // if the query went wrong then it would return null
    if (mReceipts == null) {
      setState(() {
        eventMessage = "Item Retrieval Failed.";
        eventMessageColor = Colors.red;
      });

      // clears the event message after 2 seconds have passed
      clearEventMessage(2000);
      return;
    }

    // upon refresh, reset the lists that keeps track of the items that are showing on the UI
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
  void expandItem(int itemIndex) {
    bool expandedState = !receiptExpandedStateSet[itemIndex]; // invert the state
    receiptExpandedStateSet[itemIndex] = expandedState;
    setState(() {
      receiptWidgets[itemIndex] =
          getReceiptWidget(itemIndex, expandedState);
    });
  }

  // returns a widget that represents a business item
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
                    receipts[i].getId().toString(),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 20,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => {expandItem(i)},
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
                              "CUSTOMER ID: " + receipts[i].getCustomerId().toString(),
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
                              "DATE: " + receipts[i].getDateTime(),
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
                              "MERCHANT ID: " + receipts[i].getMerchantId().toString(),
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
        title: const Text('Receipt History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Open the drop down
            ElevatedButton(
              child: const Text('Filter'),
              onPressed: _showFilter,
            ),
            ElevatedButton(
              child: const Text('Sort'),
              onPressed: _showFilter,
            ),
            const Divider(
              height: 30,
            ),
            // display selected items
            Wrap(
              children: _choices
                  .map((e) => Chip(
                label: Text(e),
              ))
                  .toList(),
            ),
            ElevatedButton(
              child: const Text('Get Receipts'),
              onPressed: _getReceipts,
            ),
          ],
        ),
      ),
    );
  }
}