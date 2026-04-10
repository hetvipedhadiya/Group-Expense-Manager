import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery/Models/PersonModel.dart';
import 'package:grocery/Person_Api.dart';
import 'package:image_picker/image_picker.dart';

class PersonForm extends StatefulWidget {
  final String eventName;
  final Map<String, dynamic>? map;
  final int eventID;

  PersonForm({this.map, required this.eventName, required this.eventID});

  @override
  State<PersonForm> createState() => _PersonFormState();
}

class _PersonFormState extends State<PersonForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  // File? _selectedImage;
  // String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ));

    _animationController.forward();

    if (widget.map != null) {
      _userNameController.text = widget.map!['userName'] ?? '';
    //  _imageUrl = widget.map!['UserImage'];
    }
  }
  //
  // Future<void> _pickImage() async {
  //   final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _selectedImage = File(pickedFile.path);
  //     });
  //   }
  // }

  Future<void> _addOrUpdateUser() async {
    if (!_formKey.currentState!.validate()) return;




    setState(() {
      isLoading = true;
    });

    try {
      print("Uploading user..."); // Debug log

      PersonModel personModel = PersonModel(
        userID: widget.map?['userID'],
        userName: _userNameController.text.trim(),
        eventID: widget.eventID,
        //UserImage: uploadedImageUrl ?? "", // Ensuring it's not null
      );

      bool isSuccess = widget.map != null
          ? await PersonApi().updateUser(personModel, widget.map!['userID'])
          : await PersonApi().insertUser(personModel);

      print("API response: $isSuccess"); // Debug log

      if (isSuccess) {
        Navigator.pop(context, true); // Navigate back after success
      } else {
        _showSnackBar("Failed to ${widget.map != null ? 'update' : 'add'} user.");
      }
    } catch (error) {
      print("Error: $error"); // Debug log
      _showSnackBar("Error: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<String?> uploadImageToServer(File imageFile) async {
    return "https://your-server.com/path-to-image.jpg"; // Replace with actual URL
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
        backgroundColor: Color(0xFF3E4FBD),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/welcome.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: SlideTransition(
                position: _animation,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // GestureDetector(
                            //   onTap: _pickImage,
                            //   child: CircleAvatar(
                            //     radius: 50,
                            //     backgroundColor: Colors.brown[100],
                            //     backgroundImage: _selectedImage != null
                            //         ? FileImage(_selectedImage!)
                            //         : (_imageUrl != null ? NetworkImage(_imageUrl!) : null) as ImageProvider?,
                            //     child: _selectedImage == null && _imageUrl == null
                            //         ? Icon(Icons.person, size: 50, color: Color(0xFF3E4FBD))
                            //         : null,
                            //   ),
                            // ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _userNameController,
                              decoration: InputDecoration(
                                labelText: "Person Name",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                prefixIcon: Icon(Icons.person_outline, color: Color(0xFF3E4FBD)),
                                filled: true,
                                fillColor: Colors.brown[50],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter a name";
                                } else if (value.length < 3) {
                                  return 'Please enter at least 3 characters';
                                } else if (value.length > 50) {
                                  return 'Username cannot exceed 50 characters.';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: _addOrUpdateUser,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    backgroundColor: Color(0xFF3E4FBD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(widget.map != null ? "Update" : "Add", style: TextStyle(color: Colors.white)),
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
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}