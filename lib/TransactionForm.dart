import 'package:flutter/material.dart';
import 'package:grocery/Models/TransactionModel.dart';
import 'package:grocery/TransactionAPI.dart';
import 'package:intl/intl.dart';

class TransactionForm extends StatefulWidget {
  final String eventName;
  final Map<String, dynamic>? map;
  final int eventID;

  TransactionForm({this.map, required this.eventName, required this.eventID});


  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  String transactionType = "debit";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate = DateTime.now(); // Initialize with current date
  bool isLoading = false;
  String? selectedUser;
  int? selectedUserID;

  List<dynamic> users = [];

  //dynamic? selectedUser;

  @override
  void initState() {
    super.initState();


    if (widget.map != null) {
      _nameController.text = widget.map!['userName'] ?? '';
      _amountController.text = widget.map!['amount'].toString()??"0.0";

      transactionType = widget.map!['transactionType'].toString().toLowerCase();
      _descriptionController.text = widget.map!['description']??'';
    }
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final List<dynamic> fetchedUsers = await TransactionAPI().getUserDropdown(widget.eventID); // Replace 1 with your event ID
      print("data afet fetch $fetchedUsers");
      setState(() {
        users = fetchedUsers;
      });
      print(users);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
    }
  }

  var map;
  Future<void> _addOrUpdateTransaction() async {
    print("kldjfkadfklajf");
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });


    try {

      TransactionModel transModel = TransactionModel(
        expenseID: widget.map?['expenseID'] != null ? int.tryParse(widget.map!['expenseID'].toString()) : null,
        userID: selectedUserID ?? widget.map?['userID'] ?? 0,
        eventID: widget.eventID,
        Amount: double.parse(_amountController.text),
        transactionDate: _selectedDate ?? DateTime.now(),
        transactionType: transactionType.toLowerCase(),
        description: _descriptionController.text,
      );
      // Print the JSON payload for debugging
      print("******************${transModel}");

      bool isSuccess = widget.map != null
          ? await TransactionAPI().updateTransaction(transModel, widget.map!['expenseID'])
          : await TransactionAPI().insertTransaction(transModel);

      if (isSuccess) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to ${widget.map != null ? 'update' : 'add'} transaction.")),
        );
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR IN TRANSACTION: $error")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    print("-----------------------------------------------------------");
    print('--------------- $_selectedDate');
    if (picked != null ) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Transaction', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF3E4FBD),
        centerTitle: true,
        elevation: 4,
      ),
      body: Stack(
        children: [
          Container(

            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/welcome.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 10,
                  shadowColor: Colors.brown.withOpacity(0.8),
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Transaction Type Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ChoiceChip(
                                  label : const Text("Expense"),
                                  selected: transactionType.toLowerCase() == "debit",
                                  selectedColor: Color(0xFF6373D9),
                                  onSelected: (selected) {
                                    setState(() {
                                      transactionType = "debit";
                                    });
                                  },
                                  labelStyle: TextStyle(
                                    color: transactionType.toLowerCase() == "debit" ? Colors.white : Colors.black,
                                  ),
                                ),
                                //map.eventId != null ? Text(map.eventID) : Text("dghs"),
                                const SizedBox(width: 10),
                                ChoiceChip(
                                  label: const Text("Income"),
                                  selected: transactionType.toLowerCase() == "credit",
                                  selectedColor: Color(0xFF3E4FBD),
                                  onSelected: (selected) {
                                    setState(() {
                                      transactionType = "credit";
                                    });
                                  },
                                  labelStyle: TextStyle(
                                    color: transactionType.toLowerCase() == "credit" ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // User Dropdown


                            DropdownButtonFormField<String>(
                              value: selectedUser,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedUser = newValue;
                                  selectedUserID = users.firstWhere(
                                        (user) => user['userID'].toString() == newValue,
                                    orElse: () => {'userID': null},
                                  )['userID'];
                                  print("Selected User ID: $selectedUserID"); // Debugging
                                });
                              },
                              items: users.map((user) => DropdownMenuItem<String>(
                                value: user['userID'].toString(), // Use userName as value
                                child: Text(user['userName'].toString()), // Display userName
                              )).toList(),
                              decoration: InputDecoration(
                                labelText: "Paid By",
                                prefixIcon: Icon(Icons.person),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a user';
                                }
                                return null;
                              },
                            ),


                            const SizedBox(height: 20),
                            // Amount Field
                            _buildTextField(_amountController, "Amount", Icons.attach_money,
                                keyboardType: TextInputType.number),
                            const SizedBox(height: 20),
                            // Date Picker
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                // child: _buildTextField(
                                //   TextEditingController(text: DateFormat.yMMMd().format(_selectedDate)),
                                //   "Date",
                                //   Icons.calendar_today,
                                // ),
                              ),
                            ),
                            const SizedBox(height: 20,),
                            InkWell(
                              onTap: (){
                                _selectDate(context);
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Transaction Date',
                                  border: OutlineInputBorder(),
                                  //errorText: _dateError, // Show validation error if any
                                ),
                                child: Text(
                                  _selectedDate == null
                                      ? 'No date selected'
                                      : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Description Field
                            _buildTextField(_descriptionController, "Description", Icons.description,
                                maxLines: 2),
                            const SizedBox(height: 30),
                            // Buttons Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [

                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF6373D9),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)
                                    ),
                                    onPressed: (){
                                      _addOrUpdateTransaction();
                                      // if(_formKey.currentState!.validate()){
                                      //   print("$_amountController amount value");
                                      //   print("$transactionType typeeeeeeeee value");
                                      //   _addOrUpdateTransaction().then((value) => (value) {
                                      //     setState(() {
                                      //
                                      //     });
                                      //   });
                                      // }
                                      // else{
                                      //
                                      // }
                                      //Navigator.of(context).pop();
                                    },
                                    child: Text("ADD",style: TextStyle(color: Colors.white),)),

                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)
                                    ),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel",style: TextStyle(color: Colors.white),))

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
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      cursorColor: Colors.black,
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

}