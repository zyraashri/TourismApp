import 'dart:typed_data'; // Required for Uint8List bytes structures

class Trip {
  String destination;
  DateTime startDate;
  DateTime endDate;
  double budgetLimit;
  List<ItineraryItem> itinerary;
  List<ExpenseItem> expenses;
  List<String> attractions;
  List<String> favoriteLocations;

  // CHANGED: Store raw bytes instead of a local file path string
  Uint8List? imageBytes;

  Trip({
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.budgetLimit = 0.0,
    required this.itinerary,
    required this.expenses,
    this.imageBytes, // <-- Updated here
    List<String>? attractions,
    List<String>? favoriteLocations,
  }) : attractions = attractions ?? [],
       favoriteLocations = favoriteLocations ?? [];

  double get totalSpent => expenses.fold(0.0, (sum, item) => sum + item.amount);
  bool get isHistory => endDate.isBefore(DateTime.now());
}

class ItineraryItem {
  final int dayNumber;
  final String time;
  final String description;

  ItineraryItem({
    required this.dayNumber,
    required this.time,
    required this.description,
  });
}

class ExpenseItem {
  String title;
  double amount;
  ExpenseItem({required this.title, required this.amount});
}
