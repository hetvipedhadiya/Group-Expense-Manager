import 'package:flutter/material.dart';
import 'package:grocery/Event_Api.dart';
import 'package:grocery/Models/InsertEventModel.dart';
import 'package:intl/intl.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
  Map<String, dynamic>? map;

  CreateEventScreen({this.map});
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  TextEditingController _eventid = TextEditingController();
  TextEditingController _eventNameController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey();

  DateTime? _selectedDate;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    if (widget.map != null) {
      _eventid.text = widget.map!['eventID'].toString();
      _eventNameController.text = widget.map!['eventName'].toString();
    } else {
      _eventid.text = '0';
      _eventNameController.text = '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/welcome.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create Event',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E4FBD),
                        ),
                      ),
                      SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _eventNameController,
                              decoration: InputDecoration(
                                labelText: 'Event Name',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                prefixIcon: Icon(Icons.event, color: Color(0xFF3E4FBD)),
                                filled: true,
                                fillColor: Colors.brown[50],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter an event name";
                                } else if (value.length < 5) {
                                  return "Event Name must be at least 5 characters";
                                } else if (value.length > 100) {
                                  return "Event Name cannot exceed 100 characters";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Event Date',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                  prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF3E4FBD)),
                                  errorText: _dateError,
                                  filled: true,
                                  fillColor: Colors.brown[50],
                                ),
                                child: Text(
                                  _selectedDate == null
                                      ? 'Select a date'
                                      : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                                  style: TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (_selectedDate == null) {
                                        setState(() {
                                          _dateError = "Please select an event date";
                                        });
                                        return;
                                      }
                                      await addEvent();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    backgroundColor: Color(0xFF3E4FBD),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text("Save", style: TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    backgroundColor: Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text("Cancel", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addEvent() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.event, color: Color(0xFF3E4FBD),),
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
      return;
    }

    Event event;
    bool isEventCreated;

    if (widget.map != null) {
      event = Event(
        eventID: widget.map!['eventID'],
        eventName: _eventNameController.text,
        eventDate: _selectedDate!,
        //hostID: widget.map!['hostId']
      );
      isEventCreated = await EventApi().updateData(event, widget.map!['eventID']).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating event: $error")),
        );
      });
    } else {
      event = Event(
        //hostID: widget.map!['hostId'],
        eventName: _eventNameController.text,
        eventDate: _selectedDate!,
      );
      isEventCreated = await EventApi().insertEvent(event).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding event: $error")),
        );
      });
    }

    if (isEventCreated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event added successfully!")),
      );
      Navigator.of(context).pop(true);
    }
  }
}
