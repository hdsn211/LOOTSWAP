
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../listing.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get all listings from Firestore
  Future<List<Listing>> getListings() async {
    final snapshot = await _db.collection('listings').get();

    return snapshot.docs.map((doc) {
      return Listing.fromJson({
        ...doc.data(),
        'documentId': doc.id,
      });
    }).toList();
  }

  // Add a new listing to Firestore
  Future<void> addListing(Listing listing) async {
    await _db.collection('listings').add({
      'id': listing.id,
      'ownerId': listing.ownerId.isNotEmpty
          ? listing.ownerId
          : FirebaseAuth.instance.currentUser?.uid ?? '',
      'userName': listing.userName,
      'itemName': listing.itemName,
      'itemImage': listing.itemImage,
      'rarity': listing.rarity,
      'category': listing.category,
      'description': listing.description,
      'isAvailable': listing.isAvailable,
      'tradeFor': listing.tradeFor,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update an existing listing using its Firestore document ID.
  Future<void> updateListing(Listing listing) async {
    if (listing.documentId.isEmpty) {
      throw ArgumentError('A Firestore document ID is required to update.');
    }

    await _db.collection('listings').doc(listing.documentId).update({
      'userName': listing.userName,
      'itemName': listing.itemName,
      'itemImage': listing.itemImage,
      'rarity': listing.rarity,
      'category': listing.category,
      'description': listing.description,
      'isAvailable': listing.isAvailable,
      'tradeFor': listing.tradeFor,
    });
  }

  // Delete a listing using its Firestore document ID
  Future<void> deleteListing(String documentId) async {
    if (documentId.isEmpty) {
      throw ArgumentError('A Firestore document ID is required to delete.');
    }

    await _db.collection('listings').doc(documentId).delete();
  }
}
