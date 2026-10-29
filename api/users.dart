import 'dart:convert';

LootSwapListings lootSwapListingsFromJson(String str) =>
    LootSwapListings.fromJson(json.decode(str));

class LootSwapListings {
  LootSwapListings({required this.data});

  final List<Listing> data;

  factory LootSwapListings.fromJson(Map<String, dynamic> json) {
    return LootSwapListings(
      data: List<Listing>.from(
        (json['data'] ?? []).map((x) => Listing.fromJson(x)),
      ),
    );
  }
}

class Listing {
  Listing({
    required this.id,
    required this.userName,
    required this.itemName,
    required this.itemImage,
    required this.rarity,
    required this.category,
    required this.description,
    required this.isAvailable,
    required this.tradeFor,
  });

  final int id;
  final String userName;
  final String itemName;
  final String itemImage;
  final String rarity;
  final String category;
  final String description;
  final bool isAvailable;
  final String tradeFor;

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] ?? 0,
      userName: json['userName'] ?? '',
      itemName: json['itemName'] ?? '',
      itemImage: json['itemImage'] ?? '',
      rarity: json['rarity'] ?? 'Common',
      category: json['category'] ?? 'RPG Item',
      description: json['description'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      tradeFor: json['tradeFor'] ?? '',
    );
  }
}
