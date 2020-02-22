import 'package:flutter/material.dart';
import 'package:bitcoin_ticker/coin_data.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert';

const URL = 'https://apiv2.bitcoinaverage.com/indices/global/ticker/';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = 'USD';

  List<String> valueList;

  dynamic getData({String coin}) async {
    var response = await http.get('$URL$coin$selectedCurrency');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('status code: ${response.statusCode}');
    }
  }

  void updateUI() async {
    valueList = ['?', '?', '?'];

    List<String> temp = ['', '', ''];

    for (int index = 0; index < cryptoList.length; index++) {
      String crypto = cryptoList[index];
      var response = await getData(coin: crypto);
      double a = response['last'];
      temp[index] = a.toString();
    }

    setState(() {
      valueList = temp;
    });
  }

  DropdownButton androidDropdown() {
    List<DropdownMenuItem> dropdownMenuItems = [];
    for (String currency in currenciesList) {
      dropdownMenuItems.add(
        DropdownMenuItem(
          child: Text(currency),
          value: currency,
        ),
      );
    }

    return DropdownButton(
      value: selectedCurrency,
      items: dropdownMenuItems,
      onChanged: (value) {
        print(value);
        setState(() {
          selectedCurrency = value;
          updateUI();
        });
      },
    );
  }

  CupertinoPicker iOSPicker() {
    List<Text> pickerItems = [];
    for (String currency in currenciesList) {
      pickerItems.add(
        Text(currency),
      );
    }

    return CupertinoPicker(
      backgroundColor: Colors.lightBlue,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        selectedCurrency = currenciesList[selectedIndex];
        updateUI();
      },
      children: pickerItems,
    );
  }

  List<Widget> getCard() {
    List<Widget> cards = [];
    for (int index = 0; index < cryptoList.length; index++) {
      String crypto = cryptoList[index];
      String value = valueList[index];
      cards.add(
        Card(
          color: Colors.lightBlueAccent,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
            child: Text(
              '1 $crypto = $value $selectedCurrency',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return cards;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateUI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
            child: Column(
              children: getCard(),
            ),
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS ? iOSPicker() : androidDropdown(),
          ),
        ],
      ),
    );
  }
}
