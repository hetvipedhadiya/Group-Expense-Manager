import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grocery/models/transaction_model.dart';
import 'package:grocery/transaction_database.dart';
import 'package:grocery/theme_manager.dart';
import 'package:intl/intl.dart';

class TransactionFormScreen extends StatefulWidget {
  final String eventName;
  final Map<String, dynamic>? map;
  final int eventID;

  TransactionFormScreen({this.map, required this.eventName, required this.eventID});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _transactionType = 'debit';
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();
  bool _isLoading = false;
  int? _selectedUserID;
  List<dynamic> _users = [];

  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();

    if (widget.map != null) {
      _amountController.text = widget.map!['amount'].toString();
      _transactionType = widget.map!['transactionType'].toString().toLowerCase();
      _descriptionController.text = widget.map!['description'] ?? '';
      _selectedUserID = widget.map!['userID'];
    }
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final users = await TransactionDatabase().getUserDropdown(widget.eventID);
    if (mounted) setState(() => _users = users);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUserID == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a member')));
      return;
    }

    setState(() => _isLoading = true);
    final model = TransactionModel(
      expenseID: widget.map != null ? int.tryParse(widget.map!['expenseID'].toString()) : null,
      userID: _selectedUserID!,
      eventID: widget.eventID,
      Amount: double.parse(_amountController.text),
      transactionDate: _selectedDate ?? DateTime.now(),
      transactionType: _transactionType,
      description: _descriptionController.text,
    );

    final success = widget.map != null 
        ? await TransactionDatabase().updateTransaction(model, widget.map!['expenseID']) 
        : await TransactionDatabase().insertTransaction(model);

    if (success) Navigator.of(context).pop(true);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = ThemeManager.instance.isLightMode;
    final secondaryBg = isLight ? const Color(0xFFF8FAFC) : Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: isLight ? Colors.white : const Color(0xFF0D0D1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: isLight ? Colors.black87 : Colors.white70), onPressed: () => Navigator.pop(context)),
        title: Text(widget.map != null ? 'Edit Transaction' : 'Add Transaction', style: TextStyle(color: isLight ? const Color(0xFF0F172A) : Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // TRANSACTION TYPE TOGGLE
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: secondaryBg, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _TypeToggle(label: 'EXPENSE', isSelected: _transactionType == 'debit', onTap: () => setState(() => _transactionType = 'debit'), isLight: isLight),
                          _TypeToggle(label: 'INCOME', isSelected: _transactionType == 'credit', onTap: () => setState(() => _transactionType = 'credit'), isLight: isLight),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _label('MEMBER', isLight),
                  const SizedBox(height: 12),
                  _buildDropdown(secondaryBg, isLight),
                  const SizedBox(height: 32),

                  _label('AMOUNT', isLight),
                  const SizedBox(height: 12),
                  _buildInputField(controller: _amountController, icon: Icons.account_balance_wallet, hint: '0.00', keyboardType: TextInputType.number, bg: secondaryBg, isLight: isLight),
                  const SizedBox(height: 32),

                  _label('DATE', isLight),
                  const SizedBox(height: 12),
                  _buildDatePicker(context, secondaryBg, isLight),
                  const SizedBox(height: 32),

                  _label('DESCRIPTION (OPTIONAL)', isLight),
                  const SizedBox(height: 12),
                  _buildInputField(controller: _descriptionController, icon: Icons.short_text, hint: 'Details...', maxLines: 3, bg: secondaryBg, isLight: isLight, isRequired: false),
                  const SizedBox(height: 40),

                  // SUBMIT BUTTON
                  GestureDetector(
                    onTap: _isLoading ? null : _submit,
                    child: Container(
                      height: 64, width: double.infinity,
                      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))]),
                      child: Center(
                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(widget.map != null ? 'Update Transaction' : 'Add Transaction', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)))),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, bool isLight) => Text(text, style: TextStyle(color: isLight ? const Color(0xFF64748B) : Colors.white38, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1));

  Widget _buildDropdown(Color bg, bool isLight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<int>(
          value: _selectedUserID,
          hint: Text('Select Member', style: TextStyle(color: isLight ? Colors.black38 : Colors.white24)),
          dropdownColor: isLight ? Colors.white : const Color(0xFF1E293B),
          decoration: InputDecoration(border: InputBorder.none, prefixIcon: Icon(Icons.people_alt_outlined, color: isLight ? const Color(0xFF1E293B) : Colors.white70, size: 22)),
          items: _users.map((u) {
            String? imagePath = u['userImage'];
            return DropdownMenuItem<int>(
              value: u['userID'],
              child: Row(
                children: [
                  CircleAvatar(radius: 14, backgroundImage: (imagePath != null && imagePath.isNotEmpty) ? FileImage(File(imagePath)) : null, child: (imagePath == null || imagePath.isEmpty) ? const Icon(Icons.person, size: 16) : null),
                  const SizedBox(width: 12),
                  Text(u['userName'].toString(), style: TextStyle(color: isLight ? const Color(0xFF1E293B) : Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedUserID = val),
        ),
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required Color bg, required bool isLight, required IconData icon, required String hint, TextInputType keyboardType = TextInputType.text, int maxLines = 1, bool isRequired = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: isLight ? const Color(0xFF1E293B) : Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        decoration: InputDecoration(
          border: InputBorder.none, hintText: hint, hintStyle: TextStyle(color: isLight ? Colors.black26 : Colors.white10),
          prefixIcon: Icon(icon, color: isLight ? const Color(0xFF1E293B) : Colors.white70, size: 22),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
        validator: isRequired ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, Color bg, bool isLight) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined, color: isLight ? const Color(0xFF1E293B) : Colors.white70, size: 22),
            const SizedBox(width: 12),
            Text(DateFormat('dd MMMM yyyy').format(_selectedDate ?? DateTime.now()), style: TextStyle(color: isLight ? const Color(0xFF1E293B) : Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.black12),
          ],
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLight;

  const _TypeToggle({required this.label, required this.isSelected, required this.onTap, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(color: isSelected ? (isLight ? Colors.white : const Color(0xFF1E293B)) : Colors.transparent, borderRadius: BorderRadius.circular(12), boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null),
        child: Text(label, style: TextStyle(color: isSelected ? const Color(0xFFEF4444) : (isLight ? Colors.black26 : Colors.white24), fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
      ),
    );
  }
}


