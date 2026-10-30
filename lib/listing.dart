
import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  const Listing({
    required this.id,
    required this.userName,
    required this.itemName,
    required this.itemImage,
    required this.rarity,
    required this.category,
    required this.description,
    required this.isAvailable,
    required this.tradeFor,
    this.documentId = '',
    this.ownerId = '',
    this.createdAt,
  });

  final int id;
  final String documentId;
  final String ownerId;
  final DateTime? createdAt;
  final String userName;
  final String itemName;
  final String itemImage;
  final String rarity;
  final String category;
  final String description;
  final bool isAvailable;
  final String tradeFor;

  factory Listing.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['createdAt'];

    return Listing(
      id: (json['id'] as num?)?.toInt() ?? 0,
      documentId: json['documentId'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : null,
      userName: json['userName'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      itemImage: json['itemImage'] as String? ?? '',
      rarity: json['rarity'] as String? ?? 'Common',
      category: json['category'] as String? ?? 'RPG Item',
      description: json['description'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      tradeFor: json['tradeFor'] as String? ?? '',
    );
  }
}
