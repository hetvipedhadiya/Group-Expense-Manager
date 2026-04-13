import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grocery/models/person_model.dart';
import 'package:grocery/person_database.dart';
import 'package:grocery/theme_manager.dart';
import 'package:image_picker/image_picker.dart';

class PersonFormScreen extends StatefulWidget {
  final String eventName;
  final Map<String, dynamic>? map;
  final int eventID;

  PersonFormScreen({this.map, required this.eventName, required this.eventID});

  @override
  State<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends State<PersonFormScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _slideController.forward();
    _fadeController.forward();

    if (widget.map != null) {
      _userNameController.text = widget.map!['userName'] ?? '';
      if (widget.map!['userImage'] != null && widget.map!['userImage'] != '') {
        _selectedImage = File(widget.map!['userImage']);
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final isLight = ThemeManager.instance.isLightMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : const Color(0xFF1A1040),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: isLight ? Colors.black26 : Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: isLight ? const Color(0xFF0F172A) : Colors.white),
                title: Text('Choose from Gallery', style: TextStyle(color: isLight ? const Color(0xFF0F172A) : Colors.white, fontWeight: FontWeight.bold)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: isLight ? Colors.black.withOpacity(0.03) : Colors.white.withOpacity(0.08),
                onTap: () {
                  Navigator.of(context).pop();
                  _processImagePicker(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: isLight ? const Color(0xFF0F172A) : Colors.white),
                title: Text('Take a Photo', style: TextStyle(color: isLight ? const Color(0xFF0F172A) : Colors.white, fontWeight: FontWeight.bold)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: isLight ? Colors.black.withOpacity(0.03) : Colors.white.withOpacity(0.08),
                onTap: () {
                  Navigator.of(context).pop();
                  _processImagePicker(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processImagePicker(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
    }
  }

  Future<void> _addOrUpdateUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final PersonModel personModel = PersonModel(
        userID: widget.map?['userID'],
        userName: _userNameController.text.trim(),
        userImage: _selectedImage?.path,
        eventID: widget.eventID,
      );

      final bool isSuccess = widget.map != null
          ? await PersonDatabase().updateUser(personModel, widget.map!['userID'])
          : await PersonDatabase().insertUser(personModel);

      if (isSuccess) {
        Navigator.pop(context, true);
      } else {
        _showSnackBar(
            'Failed to ${widget.map != null ? 'update' : 'add'} person.',
            isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.map != null;
    final isLight = ThemeManager.instance.isLightMode;

    return Scaffold(
      backgroundColor: isLight ? Colors.white : const Color(0xFF0D0D1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isLight ? Colors.black87 : Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Member' : 'Add Member',
          style: TextStyle(
            color: isLight ? const Color(0xFF0F172A) : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Profile Image Upload UI (Matching the requested design precisely)
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isLight ? Colors.black.withOpacity(0.08) : Colors.white.withOpacity(0.15),
                              width: 1,
                            ),
                            color: isLight ? const Color(0xFFF8FAFC) : Colors.white.withOpacity(0.05),
                          ),
                          child: ClipOval(
                            child: _selectedImage != null
                                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                : Center(
                                    child: Icon(
                                      Icons.person_add_outlined,
                                      size: 54,
                                      color: isLight ? Colors.black38 : Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isLight ? const Color(0xFF1E293B) : const Color(0xFF7C3AED),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                // Form Card (Matching the user's uploaded design)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: isLight ? Colors.white : Colors.white.withOpacity(0.05),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isLight ? 0.04 : 0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: isLight ? Colors.black.withOpacity(0.03) : Colors.white.withOpacity(0.08)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _userNameController,
                          style: TextStyle(
                              color: isLight ? const Color(0xFF0F172A) : Colors.white, 
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'Name',
                            hintStyle: TextStyle(
                                color: isLight ? Colors.black38 : Colors.white.withOpacity(0.25),
                                fontSize: 15),
                            prefixIcon: Icon(Icons.badge_outlined,
                                color: isLight ? Colors.black54 : Colors.white.withOpacity(0.4), size: 22),
                            filled: true,
                            fillColor: isLight ? const Color(0xFFF8FAFC) : Colors.black.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Name is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        GestureDetector(
                          onTap: _isLoading ? null : _addOrUpdateUser,
                          child: Container(
                            height: 64,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isLight ? const Color(0xFF1E293B) : const Color(0xFF7C3AED),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isLight ? [] : [
                                BoxShadow(
                                  color: const Color(0xFF7C3AED).withOpacity(0.3),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      isEdit ? 'Update Member' : 'Add Member',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Event: ${widget.eventName}',
                  style: TextStyle(
                    color: isLight ? Colors.black38 : Colors.white.withOpacity(0.3),
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


