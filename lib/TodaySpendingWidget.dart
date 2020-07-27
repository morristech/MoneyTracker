import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'database_helpers.dart';

class TodaySpendingWidget extends StatefulWidget {
  final Map<String, double> data;
  final List<Entry> todaySpendings;

  TodaySpendingWidget({Key key, this.data, this.todaySpendings}) : super(key: key);

  @override
  State createState() => _TodaySpendingState();
}

class _TodaySpendingState extends State<TodaySpendingWidget> {
  NumberFormat moneyNf = NumberFormat.simpleCurrency(decimalDigits: 2);
  int remaining, saved;

  Widget _moneyText(double a) {
    // round value to two decimal
    int rounded = (a * 100).toInt();
    a = rounded/100;

    return Center(
        child: Text(moneyNf.format(a),
            style: TextStyle(fontSize: 40.0, color: getColor(a))));
  }

  Color getColor(i) {
    if (i < 0) return Colors.red;
    if (i > 0) return Colors.lightGreen;
    return Colors.black;
  }

  _popUpMenuButton(Entry i) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      onSelected: (newValue) { // add this property
        if(newValue == 1){
          widget.data["todaySpent"] -= i.amount;
          widget.todaySpendings.remove(i);
          _DBDelete(i.id);
        }
        setState(() {
        });
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Text("Edit"),
          value: 0,
        ),
        PopupMenuItem(
          child: Text("Delete"),
          value: 1,
        ),
      ],
    );
  }

  getTimeText(Entry i){
    DateTime dt = new DateTime.fromMillisecondsSinceEpoch(i.timestamp);
    return "\t\t(" + DateFormat('h:mm a').format(dt) + ")";
  }

  List<Widget> spendingHistory(){
    List<Widget> history = new List<Widget>();
    for(Entry i in widget.todaySpendings.reversed){
      history.add(
          new Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              margin: EdgeInsets.all(5.0),
              color: Colors.white,
              child: ListTile(
                dense: true,
                title: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: moneyNf.format(i.amount), style: TextStyle(color: Colors.black)),
                      TextSpan(text: getTimeText(i), style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                subtitle: Text(i.content),
                trailing: _popUpMenuButton(i)
              )
          )
      );
    }
    return history;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 25, 0, 20),
            child: Center(
              child: Text(
                  "Today's Spending",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )
              ),
            ),

          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: spendingHistory()
          )
        ]
      )
    );
  }

  _DBDelete(int id) async{
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.delete(id);
    print("delete entry: " + id.toString());
  }
}