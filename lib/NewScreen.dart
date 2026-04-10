import 'package:flutter/material.dart';
import 'package:grocery/DeveloperScreenPage.dart';
import 'package:grocery/Event_Api.dart';
import 'package:grocery/ExpenseDetail.dart';
import 'package:grocery/FormScreen.dart';
import 'package:grocery/LoginPage.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewScreen extends StatefulWidget {
  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  Future<List<dynamic>>? _futureEvents;
  @override
  void initState() {
    super.initState();
    _futureEvents = EventApi().fetchEventsByHostId();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3E4FBD),
        title: Text(
          "Group Expense Manager",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          PopupMenuButton(
              color: Colors.white,
              icon: Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'share') {
                  String message =
                      'https://play.google.com/store/apps/details?id=com.aswdc_expense_manager';
                  Share.share(message);
                }
                else if (value == 'developer') {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>DeveloperScreenPage()));
                }
                else if (value == 'close') {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>NewScreen()));
                }
              },
              itemBuilder: (BuildContext context) => [
                    PopupMenuItem(value: 'share', child: Text("Share")),
                    PopupMenuItem(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DeveloperScreenPage()));
                        },
                        value: 'developer',
                        child: Text("Developer")),
                    PopupMenuItem(value: 'close', child: Text("Close")),
                PopupMenuItem(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('hostID'); // Remove the saved login

                    // Navigate to LoginScreen and remove all previous routes
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false,
                    );
                  },
                    value: 'logout', child: Text("Logout")
                )
                  ])
        ],

      ),
      body: FutureBuilder(
        future: _futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }   else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            // Removed Expanded because FutureBuilder should not be wrapped inside Expanded
            return ListView.builder(
              // physics: BouncingScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var event = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ExpenseDetail(
                                    eventName: event['eventName'],
                                    eventId: event['eventID'],
                                  ))).then((value) {
                        Future<List<dynamic>>? temp = EventApi().fetchEventsByHostId();
                                    setState(() {
                                        _futureEvents = temp;
                                    });
                                  },);
                    },
                    onDoubleTap: () {
                      // Show the popup menu on double-tap
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Actions'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.edit, color: Colors.blue),
                                  title: Text('Edit'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateEventScreen(map: event),
                                      ),
                                    ).then((value) {
                                      if (value == true) {
                                        setState(() {
                                          _futureEvents = EventApi().fetchEventsByHostId();
                                        });

                                        // Close the edit/delete dialog
                                        Navigator.of(context).pop();

                                        // Show fancy snackbar
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(Icons.edit, color: Color(0xFF3E4FBD)),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    "Event updated successfully!",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            margin: EdgeInsets.all(16),
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    });
                                  },

                                ),
                                Divider(),
                                ListTile(
                                  leading:
                                      Icon(Icons.delete, color: Colors.red),
                                  title: Text('Delete'),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Are you sure?'),
                                          content: Text(
                                              'Do you really want to delete this event?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the confirmation dialog
                                              },
                                              child: Text('No',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                try {
                                                  bool isDeleted =
                                                      await EventApi()
                                                          .deleteEvent(
                                                              event['eventID']);

                                                  if (isDeleted) {
                                                    // Show Snackbar **before** closing the dialogs
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Row(
                                                          children: [
                                                            Icon(Icons.event,
                                                                color: Color(
                                                                    0xFF3E4FBD)),
                                                            SizedBox(width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                "Event deleted successfully!",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        backgroundColor:
                                                            Colors.white,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        margin:
                                                            EdgeInsets.all(16),
                                                        duration: Duration(
                                                            seconds: 3),
                                                      ),
                                                    );

                                                    // Delay to allow Snackbar to display before closing the dialog
                                                    await Future.delayed(
                                                        Duration(
                                                            milliseconds: 500));

                                                    Navigator.of(context)
                                                        .pop(); // Close the confirmation dialog
                                                    Navigator.of(context)
                                                        .pop(); // Close the edit/delete popup menu

                                                    setState(
                                                        () {
                                                          _futureEvents = EventApi().fetchEventsByHostId();
                                                        }); // Refresh the UI after deletion
                                                  } else {
                                                    throw Exception(
                                                        "Failed to delete event");
                                                  }
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Row(
                                                        children: [
                                                          Icon(Icons.warning,
                                                              color:
                                                                  Colors.red),
                                                          SizedBox(width: 8),
                                                          Expanded(
                                                            child: Text(
                                                              "Event could not be deleted due to related data!",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      backgroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      margin:
                                                          EdgeInsets.all(16),
                                                      duration:
                                                          Duration(seconds: 3),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Text('Yes',
                                                  style: TextStyle(
                                                      color: Colors.green)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  child: Icon(Icons.person),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  event['eventName'] ?? 'No Name',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                //Text("EventDate"),
                                Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF3E4FBD),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  event['eventDate']?.substring(0, 10) ??
                                      'No Date',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Color(0xFF3E4FBD),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Total Expense: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹ ${NumberFormat("#,##,##0", "en_IN").format(event['amount'] ?? 0)}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: Container(
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: Color(0xFF3E4FBD)),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent, // Transparent to show gradient
          elevation: 0, // No shadow to blend seamlessly
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateEventScreen()),
              ).then((value) {
                if (value == true) {
                  setState(() {
                    _futureEvents = EventApi().fetchEventsByHostId();
                  });

                  // Show fancy snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.event, color: Color(0xFF3E4FBD)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Event added successfully!",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.all(16),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              });
            },

            child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
