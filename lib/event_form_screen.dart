import 'package:flutter/material.dart';
import 'package:grocery/event_database.dart';
import 'package:grocery/models/insert_event_model.dart';
import 'package:grocery/theme_manager.dart';
import 'package:intl/intl.dart';

class EventFormScreen extends StatefulWidget {
  final Map<String, dynamic>? map;
  EventFormScreen({this.map});

  @override
  _EventFormScreenState createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> with TickerProviderStateMixin {
  final TextEditingController _eventNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  DateTime? _selectedDate;
  bool _isLoading = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _slideController.forward();
    _fadeController.forward();

    if (widget.map != null) {
      _eventNameController.text = widget.map!['eventName'].toString();
      final dateStr = widget.map!['eventDate']?.toString().substring(0, 10);
      if (dateStr != null) _selectedDate = DateTime.tryParse(dateStr);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _eventNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showSnackBar('Please select an event date', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      bool success;
      if (widget.map != null) {
        final event = Event(
          eventID: widget.map!['eventID'],
          eventName: _eventNameController.text.trim(),
          eventDate: _selectedDate!,
        );
        success = await EventDatabase().updateData(event, widget.map!['eventID']);
      } else {
        final event = Event(
          eventName: _eventNameController.text.trim(),
          eventDate: _selectedDate!,
        );
        success = await EventDatabase().insertEvent(event);
      }
      if (success) Navigator.of(context).pop(true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green[800],
        behavior: SnackBarBehavior.floating,
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
          isEdit ? 'Edit Event' : 'New Event',
          style: TextStyle(color: isLight ? const Color(0xFF0F172A) : Colors.white, fontWeight: FontWeight.bold),
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
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLight ? const Color(0xFFF1F5F9) : Colors.white.withOpacity(0.05),
                      border: Border.all(color: isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.1)),
                    ),
                    child: Icon(Icons.calendar_month_outlined, size: 50, color: isLight ? const Color(0xFF1E293B) : Colors.white30),
                  ),
                ),
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(isLight ? 0.04 : 0.2), blurRadius: 40, offset: const Offset(0, 10)),
                    ],
                    border: Border.all(color: isLight ? Colors.black.withOpacity(0.03) : Colors.white.withOpacity(0.08)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _eventNameController,
                          style: TextStyle(color: isLight ? const Color(0xFF0F172A) : Colors.white, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'Event Name',
                            prefixIcon: const Icon(Icons.edit_note, size: 22),
                            filled: true,
                            fillColor: isLight ? const Color(0xFFF8FAFC) : Colors.black.withOpacity(0.2),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            decoration: BoxDecoration(
                              color: isLight ? const Color(0xFFF8FAFC) : Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedDate == null ? 'Select Date' : DateFormat('dd MMM yyyy').format(_selectedDate!),
                                  style: TextStyle(color: isLight ? Colors.black87 : Colors.white, fontSize: 16),
                                ),
                                const Spacer(),
                                const Icon(Icons.expand_more, color: Colors.black26),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        GestureDetector(
                          onTap: _isLoading ? null : _saveEvent,
                          child: Container(
                            height: 64,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(isEdit ? 'Update Event' : 'Create Event', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
                      ],
                    ),
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



