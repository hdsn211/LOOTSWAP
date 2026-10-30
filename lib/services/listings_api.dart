import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../listing.dart';

class ListingsApi {
  ListingsApi({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<List<Listing>> getListings() async {
    final response = await _request('GET', '/listings');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((item) => Listing.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Listing> createListing(Listing listing) async {
    final response = await _request('POST', '/listings', body: {
      'userName': listing.userName,
      'itemName': listing.itemName,
      'itemImage': listing.itemImage,
      'rarity': listing.rarity,
      'category': listing.category,
      'description': listing.description,
      'isAvailable': listing.isAvailable,
      'tradeFor': listing.tradeFor,
    });
    return Listing.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Listing> updateListing(Listing listing) async {
    final response = await _request('PUT', '/listings/${listing.documentId}',
        body: {
      'itemName': listing.itemName,
      'itemImage': listing.itemImage,
      'rarity': listing.rarity,
      'category': listing.category,
      'description': listing.description,
      'isAvailable': listing.isAvailable,
      'tradeFor': listing.tradeFor,
    });
    return Listing.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteListing(String documentId) async {
    await _request('DELETE', '/listings/$documentId');
  }

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    if (token == null) throw StateError('Please sign in first.');

    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
    if (body != null) request.body = jsonEncode(body);

    final response = await _client.send(request).then(http.Response.fromStream);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Listings API failed: ${response.statusCode}');
    }
    return response;
  }
}
