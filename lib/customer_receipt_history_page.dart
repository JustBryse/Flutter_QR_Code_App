import 'package:ceg4912_project/Models/receipt.dart';
import 'package:ceg4912_project/Support/session.dart';
import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/Support/utility.dart';
import 'package:ceg4912_project/customer_home.dart';
import 'package:ceg4912_project/customer_scanned_receipt_page.dart';
import 'package:flutter/material.dart';

var merchantName = "Amazon";

class CustomerReceiptHistoryPageRoute extends StatelessWidget {
  const CustomerReceiptHistoryPageRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CustomerReceiptHistoryPage());
  }
}



class CustomerReceiptHistoryPage extends StatefulWidget {
  const CustomerReceiptHistoryPage({Key? key}) : super(key: key);

  @override
  _ReceiptHistoryState createState() => _ReceiptHistoryState();
}

//Class for the receipt history state
class _ReceiptHistoryState extends State<CustomerReceiptHistoryPage> {
  // list of selected filters
  List<String> _choices = [];

  //New
  // list of receipts
  List<Receipt> receipts = <Receipt>[];
  // stores the UI widgets that represent merchant's receipts
  List<Widget> receiptWidgets = <Widget>[];
  // keeps track of which receipt widgets are expanded in the UI
  List<bool> receiptExpandedStateSet = <bool>[];


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

  // generates widgets for all of the current merchant's business receipt
  void _getReceipts() async {
    int cId = Session.getSessionUser().getId();
    var conn = await Queries.getConnection();
    var cReceipts = await Queries.getCustomerReceipts(conn, cId);

    // if the query went wrong then it would return null
    if (cReceipts == null) {
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

    for (int i = 0; i < cReceipts.length; i++) {
      receipts.add(cReceipts[i]);
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
                ),
                IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CustomerScannedReceiptPage(receiptID: receipts[i].getId()
                          )
                      )
                  ),
                  icon: const Icon(
                    Icons.list,
                    color: Colors.orange,
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
                builder: (_) => const CustomerHomePage(
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
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Divider(
              height: 30,
            ),
                Column(children: receiptWidgets),

            // displays event messages to the user
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
