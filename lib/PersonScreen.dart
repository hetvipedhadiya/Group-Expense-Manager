import 'package:flutter/material.dart';
import 'package:grocery/Event_Api.dart';
import 'package:grocery/PersonForm.dart';
import 'package:grocery/Person_Api.dart';

class PersonScreen extends StatefulWidget {
  final int eventId;
  final String eventName;

  PersonScreen({required this.eventId, required this.eventName});

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  late Future<List<dynamic>> _personsFuture;

  @override
  void initState() {
    super.initState();
    _personsFuture = _fetchEventWisePersons();
  }

  Future<List<dynamic>> _fetchEventWisePersons() async {
    return await EventApi().getById(widget.eventId);
  }

  void _refreshPersons() {
    setState(() {
      _personsFuture = _fetchEventWisePersons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<dynamic>>(
        future: _personsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No Persons Found"));
          }

          final persons = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(persons.length),
                SizedBox(height: 20),
                ...persons.map((person) => _buildPersonCard(person)).toList(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF3E4FBD)
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () async {
            bool? result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PersonForm(
                  eventID: widget.eventId,
                  eventName: widget.eventName,
                ),
              ),
            );
            if (result == true) {
              _refreshPersons();
            }
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
       color: Color(0xFF3E4FBD),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            offset: Offset(2, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Total Persons: $count",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(dynamic person) {
    String? imageUrl = person['UserImage']; // Get image URL

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              offset: Offset(2, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                ? NetworkImage(imageUrl) // Display image if available
                : null, // Otherwise, show default icon
            child: imageUrl == null || imageUrl.isEmpty
                ? Icon(Icons.person, color: Color(0xFF3E4FBD), size: 28)
                : null,
          ),
          title: Text(
            person['userName'] ?? 'Unknown',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => _showActionDialog(person),
        ),
      ),
    );
  }


  void _showActionDialog(dynamic person) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Actions'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue),
                    title: Text('Edit'),
                    onTap: () async {
                      Navigator.pop(context);
                      bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonForm(
                            eventID: widget.eventId,
                            eventName: widget.eventName,
                            map: person,
                          ),
                        ),
                      );
                      if (result == true) {
                        _refreshPersons();
                      }
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete'),
                    onTap: () async {
                      Navigator.pop(context);
                      bool isDeleted = await PersonApi().deleteUser(person['userID']);
                      if (isDeleted) {
                        _refreshPersons();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.event, color: Color(0xFF3E4FBD),),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "User deleted successfully!",
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
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


}
