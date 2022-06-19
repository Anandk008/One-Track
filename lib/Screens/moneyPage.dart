import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mini_project_ui/Screens/first_screen.dart';
import 'package:mini_project_ui/Screens/routine.dart';
import 'package:mini_project_ui/Screens/upgradedr1.dart';
import 'package:mini_project_ui/Money_mgmt/static.dart' as Static;
import '../Money_mgmt/widgets/confirm_dialog.dart';
import '../Money_mgmt/widgets/info_snackbar.dart';
import 'fitnessPage.dart';
import 'package:mini_project_ui/Money_mgmt/add_transaction.dart';
import 'package:mini_project_ui/Money_mgmt/transaction.dart';

class MoneyPage extends StatefulWidget {
  const MoneyPage({Key? key}) : super(key: key);

  @override
  State<MoneyPage> createState() => _MoneyPageState();
}


class _MoneyPageState extends State<MoneyPage> {
  int selectedMonthIndex = 1;
  int navigationIndex=0;
  int totalBalance = 0;
  int totalIncome = 0;
  int totalExpense = 0;
  List<FlSpot> dataSet = [];
  DateTime today = DateTime.now();
  DateTime now = DateTime.now();
  int index = 1;

  final Stream<QuerySnapshot> moneyStream  = FirebaseFirestore.instance.collection('Money').snapshots();
  // final List<TransactionModel> items = List.from(TModel);
  CollectionReference money  = FirebaseFirestore.instance.collection('money');

  //
  // Future<List<TransactionModel>> fetch() async {
  //   if (box.values.isEmpty) {
  //     return Future.value([]);
  //   } else {
  //     // return Future.value(box.toMap());
  //     List<TransactionModel> items = [];
  //     box.toMap().values.forEach((element) {
  //       // print(element);
  //       items.add(
  //         TransactionModel(
  //           element['amount'] as int,
  //           element['note'],
  //           element['date'] as DateTime,
  //           element['type'],
  //         ),
  //       );
  //     });
  //     return items;
  //   }
  // }


  set appBarTitle(String appBarTitle) {}

  List months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  bool? get isCollabsed => null;


  getTotalBalance(List<TransactionModel> entireData) {
    totalBalance = 0;
    totalIncome = 0;
    totalExpense = 0;
    for (TransactionModel data in entireData) {
      if (data.date.month == today.month) {
        if (data.type == "Income") {
          totalBalance += data.amount;
          totalIncome += data.amount;
        } else {
          totalBalance -= data.amount;
          totalExpense += data.amount;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF21BFBD),
        elevation: 0,
        title: Center(child: Text(
          "Money        ", style: TextStyle(fontSize: 25),)),
        toolbarHeight: 60,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
      //
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            CupertinoPageRoute(
              builder: (context) => AddExpenseNoGradient(),
            ),
          )
              .then((value) {
            setState(() {});
          });
        },
        backgroundColor: Colors.tealAccent[400],
        child: Icon(
          Icons.add_outlined,
          size: 32.0,
        ),
      ),

      bottomNavigationBar : BottomNavigationBar(
            currentIndex: 2,
            type: BottomNavigationBarType.fixed,
            iconSize: 28,
            backgroundColor: Color(0xFF21BFBD),
            landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
            selectedItemColor: Colors.white70,
            unselectedItemColor: Colors.black,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  activeIcon: Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.white70,
                  ),
                  icon: Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.black,
                  ),
                  label: 'Fitness'),

              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.fastfood_rounded,
                    color: Colors.black,
                  ),
                  label: 'Diet'),

              BottomNavigationBarItem(
                  activeIcon: Icon(
                    Icons.attach_money_outlined,
                    color: Colors.white70,
                  ),
                  icon: Icon(
                    Icons.attach_money_outlined,
                    color: Colors.black,
                  ),
                  label: 'Money'),

              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.timer_rounded,
                    color: Colors.black,
                  ),
                  label: 'Routine'),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                    color: Colors.black,
                  ),

                  label: 'Home'),
              // BottomNavigationBarItem(icon: Icon(),label: Icons.lunch_dining_outlined),
            ],
            onTap:(int index)
            {
              setState(() {
                navigationIndex=index;
                switch(navigationIndex)
                {

                  case 0:
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(context)=>FitnessPage()), (route) => (route.isFirst));
                    break;
                  case 1:
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(context)=>UpDiet()), (route) => (route.isFirst));
                    break;
                  case 2:
                    Fluttertoast.showToast(msg: 'U are on MoneyPage');
                    break;
                  case 3:
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(context)=>RoutinePage()), (route) => (route.isFirst));
                    break;
                  case 4:
                    Navigator.pop(context);
                }
              }
              );
            }
        ),
      //
      body: FutureBuilder<List<TransactionModel>>(
        // future: fetch(),
        builder: (context, snapshot) {
          // print(snapshot.data);
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Oopssss !!! There is some error !",
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "You haven't added Any Data !",
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                ),
              );
            }
            //
            getTotalBalance(snapshot.data!);
            getPlotPoints(snapshot.data!);
            return ListView(
              children: [
                //
                Padding(
                  padding: const EdgeInsets.all(
                    12.0,
                  ),
                  child: Text(
                    "${months[today.month - 1]} ${today.year}",
                    style: TextStyle(
                      fontSize: 32.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                //
                selectMonth(),
                //
                 Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: EdgeInsets.all(
                    12.0,
                  ),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Static.PrimaryColor,
                          Colors.blueAccent,
                        ],
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          24.0,
                        ),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            24.0,
                          ),
                        ),
                        // color: Static.PrimaryColor,
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        vertical: 18.0,
                        horizontal: 8.0,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Total Balance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22.0,
                              // fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 12.0,
                          ),
                          Text(
                            'Rs $totalBalance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 12.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                cardIncome(
                                  totalIncome.toString(),
                                ),
                                cardExpense(
                                  totalExpense.toString(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(
                    12.0,
                  ),
                  child: Text(
                    "${months[today.month - 1]} ${today.year}",
                    style: TextStyle(
                      fontSize: 32.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                // dataSet.isEmpty || dataSet.length < 2,
                    Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 40.0,
                          horizontal: 20.0,
                        ),
                        margin: EdgeInsets.all(
                          12.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Text(
                          "Not Enough Data to render Chart",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    // Container(
                    //     height: 400.0,
                    //     padding: EdgeInsets.symmetric(
                    //       vertical: 40.0,
                    //       horizontal: 12.0,
                    //     ),
                    //     margin: EdgeInsets.all(
                    //       12.0,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.only(
                    //         topLeft: Radius.circular(8),
                    //         topRight: Radius.circular(8),
                    //         bottomLeft: Radius.circular(8),
                    //         bottomRight: Radius.circular(8),
                    //       ),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: Colors.grey.withOpacity(0.5),
                    //           spreadRadius: 5,
                    //           blurRadius: 7,
                    //           offset:
                    //               Offset(0, 3), // changes position of shadow
                    //         ),
                    //       ],
                    //     ),
                    //     child: LineChart(
                    //       LineChartData(
                    //         borderData: FlBorderData(
                    //           show: false,
                    //         ),
                    //         lineBarsData: [
                    //           LineChartBarData(
                    //             // spots: getPlotPoints(snapshot.data!),
                    //             spots: getPlotPoints(snapshot.data!),
                    //             isCurved: false,
                    //             barWidth: 2.5,
                    //             colors: [
                    //               Static.PrimaryColor,
                    //             ],
                    //             showingIndicators: [200, 200, 90, 10],
                    //             dotData: FlDotData(
                    //               show: true,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                //
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Recent Transactions",
                    style: TextStyle(
                      fontSize: 32.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                //
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length + 1,
                  itemBuilder: (context, index) {
                    TransactionModel dataAtIndex;
                    try {
                      // dataAtIndex = snapshot.data![index];
                      dataAtIndex = snapshot.data![index];
                    } catch (e) {
                      // deleteAt deletes that key and value,
                      // hence makign it null here., as we still build on the length.
                      return Container();
                    }

                    if (dataAtIndex.date.month == today.month) {
                      if (dataAtIndex.type == "Income") {
                        return incomeTile(
                          dataAtIndex.amount,
                          dataAtIndex.note,
                          dataAtIndex.date,
                          index,
                        );
                      } else {
                        return expenseTile(
                          dataAtIndex.amount,
                          dataAtIndex.note,
                          dataAtIndex.date,
                          index,
                        );
                      }
                    } else {
                      return Container();
                    }
                  },
                ),
                //
                SizedBox(
                  height: 60.0,
                ),
              ],
            );
          } else {
            return selectMonth();
            //   Text(
            //   "Loading...",
            // );
          }
        },
      ),
    );
  }


Widget cardIncome(String value) {
  return Row(
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.white60,
          borderRadius: BorderRadius.circular(
            20.0,
          ),
        ),
        padding: EdgeInsets.all(
          6.0,
        ),
        child: Icon(
          Icons.arrow_downward,
          size: 28.0,
          color: Colors.green[700],
        ),
        margin: EdgeInsets.only(
          right: 8.0,
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Income",
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget cardExpense(String value) {
  return Row(
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.white60,
          borderRadius: BorderRadius.circular(
            20.0,
          ),
        ),
        padding: EdgeInsets.all(
          6.0,
        ),
        child: Icon(
          Icons.arrow_upward,
          size: 28.0,
          color: Colors.red[700],
        ),
        margin: EdgeInsets.only(
          right: 8.0,
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Expense",
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget expenseTile(int value, String note, DateTime date, int index) {
  var Static;
  return InkWell(
    splashColor: Static.PrimaryMaterialColor[400],
    onTap: () {
      ScaffoldMessenger.of(context).showSnackBar(
         deleteInfoSnackBar,
      );
    },
    onLongPress: () async {
      bool? answer = await showConfirmDialog(
        context,
        "WARNING",
        "This will delete this record. This action is irreversible. Do you want to continue ?",
      );
      if (answer != null && answer) {
        // await dbHelper.deleteData(index);
        setState(() {});
      }
    },
    child: Container(
      padding: const EdgeInsets.all(18.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Color(0xffced4eb),
        borderRadius: BorderRadius.circular(
          8.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_circle_up_outlined,
                        size: 28.0,
                        color: Colors.red[700],
                      ),
                      SizedBox(
                        width: 4.0,
                      ),
                      Text(
                        "Expense",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),

                  //
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      "${date.day} ${months[date.month - 1]} ",
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "- $value",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  //
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      note,
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget incomeTile(int value, String note, DateTime date, int index) {
  return InkWell(
    splashColor: Static.PrimaryMaterialColor[400],
    onTap: () {
      SnackBar deleteInfoSnackBar;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   deleteInfoSnackBar,
      // );
    },
    onLongPress: () async {
      bool? answer = await showConfirmDialog(
        context,
        "WARNING",
        "This will delete this record. This action is irreversible. Do you want to continue ?",
      );

      // if (answer != null && answer) {
      //   await dbHelper.deleteData(index);
      //   setState(() {});
      // }
    },
    child: Container(
      padding: const EdgeInsets.all(18.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Color(0xffced4eb),
        borderRadius: BorderRadius.circular(
          8.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.arrow_circle_down_outlined,
                    size: 28.0,
                    color: Colors.green[700],
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    "Credit",
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
              //
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  "${date.day} ${months[date.month - 1]} ",
                  style: TextStyle(
                    color: Colors.grey[800],
                  ),
                ),
              ),
              //
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "+ $value",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              //
              //
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  note,
                  style: TextStyle(
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
  // monthClicked(String clickedMonth) async {
  //   selectedMonthIndex = months.indexOf(clickedMonth);
  //   appBarTitle = clickedMonth;
  //   titleClicked();
  // }

  // titleClicked() {
  //   isCollabsed = !isCollabsed;
  //   notifyListeners();
  // }

  // Another Sub App Data

  // getColor(month) {
  //   int monthIndex = months.indexOf(month);
  //   // color the selected month with
  //   if (monthIndex == selectedMonthIndex) {
  //     return Colors.orange;
  //   } else {
  //     return Colors.black;
  //   }
  // }

  // void closeMonthPicker() {
  //   isCollabsed = false;
  //   notifyListeners();
  // }

  // void titleClicked() {}
Widget selectMonth() {
  return Padding(
    padding: EdgeInsets.all(
      8.0,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              index = 4;
              today = DateTime(now.year, now.month - 2, today.day);
            });
          },
          child: Container(
            height: 50.0,
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                8.0,
              ),
              color: index == 4 ? Colors.tealAccent[400] : Colors.white,
            ),
            alignment: Alignment.center,
            child: Text(
              months[now.month - 3],
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: index == 4 ? Colors.white : Colors.teal,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              index = 2;
              today = DateTime(now.year, now.month - 1, today.day);
            });
          },
          child: Container(
            height: 50.0,
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                8.0,
              ),
              color: index == 2 ? Colors.tealAccent[400] : Colors.white,
            ),
            alignment: Alignment.center,
            child: Text(
              months[now.month - 2],
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: index == 2 ? Colors.white : Colors.teal,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              index = 1;
              today = DateTime.now();
            });
          },
          child: Container(
            height: 50.0,
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                8.0,
              ),
              color: index == 1 ? Colors.tealAccent[400] : Colors.white,
            ),
            alignment: Alignment.center,
            child: Text(
              months[now.month - 1],
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: index == 1 ? Colors.white : Colors.teal,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  List<FlSpot> getPlotPoints(List<TransactionModel> entireData) {
    dataSet = [];
    List tempdataSet = [];

    for (TransactionModel item in entireData) {
      if (item.date.month == today.month && item.type == "Expense") {
        tempdataSet.add(item);
      }
    }
    //
    // Sorting the list as per the date
    tempdataSet.sort((a, b) => a.date.day.compareTo(b.date.day));
    //
    for (var i = 0; i < tempdataSet.length; i++) {
      dataSet.add(
        FlSpot(
          tempdataSet[i].date.day.toDouble(),
          tempdataSet[i].amount.toDouble(),
        ),
      );
    }
    return dataSet;
  }


}



