import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_models.dart';

class FirebaseService {
  // Reference directly to the master travel plans collection path
  final CollectionReference _tripsCollection = 
      FirebaseFirestore.instance.collection('trips');

  // 1. CREATE: Stream a brand new document profile into cloud firestore collections
  Future<void> createNewTrip(Trip trip) async {
    await _tripsCollection.add({
      'destination': trip.destination,
      'startDate': trip.startDate.toIso8601String(),
      'endDate': trip.endDate.toIso8601String(),
      'budgetLimit': trip.budgetLimit,
      'attractions': trip.attractions,
      'favoriteLocations': trip.favoriteLocations,
      'expenses': trip.expenses.map((e) => {'title': e.title, 'amount': e.amount}).toList(),
      'itinerary': trip.itinerary.map((i) => {'dayNumber': i.dayNumber, 'time': i.time, 'description': i.description}).toList(),
      // Base64 encode the web bytes directly into database strings securely
      'imageBytesString': trip.imageBytes != null ? base64Encode(trip.imageBytes!) : null,
    });
  }

  // 2. READ: Stream continuous, live updates down to map your reactive UI lists automatically
  Stream<List<Map<String, dynamic>>> getTripsStream() {
    return _tripsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Inject firestore document id hash key
        return data;
      }).toList();
    });
  }

  // 3. UPDATE: Synchronize inline modifications (like adding an expense or itinerary item)
  Future<void> updateTripData(String docId, Map<String, dynamic> updatedData) async {
    await _tripsCollection.doc(docId).update(updatedData);
  }

  // 4. DELETE: Completely drop a document from the remote server instantly
  Future<void> deleteTrip(String docId) async {
    await _tripsCollection.doc(docId).delete();
  }
}