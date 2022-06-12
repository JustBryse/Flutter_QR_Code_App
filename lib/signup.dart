import 'package:ceg4912_project/Support/queries.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

enum roles { merchant, customer }

class _SignUpPageState extends State<SignUpPage> {
  // basic information
  String email = "";
  String password1 = "";
  String password2 = "";

  // stores the role of the user that is signing up
  roles? role = roles.customer;

  List<Widget> widgets = <Widget>[];

  void signUp() async {
    // passwords must match
    if (password1 != password2) {
      print("passwords do not match");
      return;
    }

    bool result = false;

    // create new user in database
    if (role == roles.customer) {
      var conn = await Queries.getConnection();
      result = await Queries.insertCustomer(conn, email, password1);

      print("customer creation successful? = " + result.toString());
    } else if (role == roles.merchant) {
      // WIP
      print("create a merchant account");
    }

    // go back to the login page
    if (result == true) {
      // go to login page
      print("returning to login page");
      Navigator.pop(context);
    }
  }

  // adds the fields that are unique to the merchant
  void addMerchantFields() {
    setState(() {
      for (int i = 0; i < 40; i++) {
        widgets.add(TextField(
            decoration:
                InputDecoration(labelText: 'Merchant Field ' + i.toString())));
      }
    });
    print("adding merchant fields");
  }

  // remove the fields that are unique to the merchant
  void removeMerchantFields() {
    setState(() {
      widgets.clear();
      print("clearing merchant fields");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: const Color.fromARGB(255, 46, 73, 107),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio(
                value: roles.customer,
                groupValue: role,
                onChanged: (roles? value) {
                  setState(() {
                    role = value;
                    removeMerchantFields();
                  });
                },
              ),
              const Text("Customer"),
              Radio(
                value: roles.merchant,
                groupValue: role,
                onChanged: (roles? value) {
                  setState(() {
                    role = value;
                    // add more widgets for merchant financial info
                    addMerchantFields();
                  });
                },
              ),
              const Text("Merchant"),
            ],
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (value) => email = value,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Password'),
            onChanged: (value) => password1 = value,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            onChanged: (value) => password2 = value,
          ),
          Column(
            children: widgets,
          ),
          TextButton(
            onPressed: signUp,
            child: const Text("Sign Up"),
          ),
        ],
      ),
    );
  }
}
