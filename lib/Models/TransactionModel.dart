class TransactionModel {
  int? expenseID;
  int? userID;
  int? eventID;
  double Amount;
  DateTime transactionDate;
  String transactionType;
  String? description;
  int? hostId;

  TransactionModel({
    this.expenseID,
    required this.userID,
    required this.eventID,
    required this.Amount,
    required this.transactionDate,
    required this.transactionType,
    this.description,
    this.hostId
  });

  // Convert from JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      expenseID: json['expenseID'] as int?,
      userID: json['userID'] as int?,
      eventID: json['eventID'] as int?,
      Amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      transactionType: json['transactionType'] as String,
      description: json['description'] as String?,
      hostId: json['hostId'] as int?
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'userID': userID,
      'eventID': eventID,
      'amount': Amount,
      'transactionDate': transactionDate.toIso8601String(),
      'transactionType': transactionType,
      'description': description,
      'hostId':hostId
    };

    if (expenseID != null) {
      json['expenseID'] = expenseID;
    }

    return json;
  }
}