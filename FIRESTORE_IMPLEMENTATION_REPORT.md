# LOOTSWAP Implementation Report

## Simple summary

We changed LOOTSWAP from using a fixed GitHub JSON file to using Firebase Firestore for its product listings.

Firestore is now the online database for the game items. Each item is saved as a document inside a collection called `listings`.

## What we added

### 1. Product data model

We created a shared `Listing` model. It tells the app what information each product has, such as:

- Item name
- Image URL
- Rarity
- Category
- Description
- What the owner wants to trade for
- Availability
- Owner ID
- Firestore document ID

### 2. Firestore connection

The app can now read product listings from Firestore instead of only reading the GitHub JSON file.

The app can also:

- Add a new listing
- Edit an existing listing
- Delete a listing

### 3. Add Listing screen

We added an Add Listing button and form. A signed-in user can enter the item details and save a new product to Firestore.

The app automatically saves the signed-in user's Firebase UID as the `ownerId`.

### 4. Edit and Delete features

The owner of a listing can open the three-dot menu to:

- Edit the listing
- Delete the listing

Other users do not see this menu for listings they do not own.

### 5. Product ListView

Products are shown in a vertical ListView. Each row displays the image, name, category, rarity, description, and trade information.

### 6. Search and filters

The Home page supports:

- Searching by item name
- Searching by category
- Searching by rarity
- Searching by username
- Filtering by rarity
- Filtering available items

### 7. Loading and error handling

The app shows:

- A loading indicator while products are loading
- An error message when loading fails
- A Retry button
- A message when no products match the search or filters

## HTTP API preparation

We also prepared an HTTP API for future use. The Dart file contains methods for:

- `GET` — read listings
- `POST` — create a listing
- `PUT` — update a listing
- `DELETE` — delete a listing

The HTTP API is not deployed yet. The app currently uses Firestore directly because this allows us to continue developing and testing slowly without needing to install the Firebase CLI yet.

## Important files

- `lib/Home_page.dart` — displays products, searches, filters, edits, and deletes listings.
- `lib/add_listing_page.dart` — form for creating a new listing.
- `lib/listing.dart` — product data model.
- `lib/services/firestore_service.dart` — Firestore database operations.
- `lib/services/listings_api.dart` — prepared HTTP API client.
- `functions/index.js` — prepared Firebase Cloud Functions API.
- `functions/package.json` — Cloud Functions settings and dependencies.

## What must be done in Firebase

The Firestore collection must be named:

```text
listings
```

Each listing should contain fields such as:

```text
itemName
itemImage
rarity
category
description
isAvailable
tradeFor
ownerId
createdAt
```

Existing listings without `ownerId` will still appear, but their owner will not see the edit/delete menu until the correct Firebase UID is added.

## Current limitations

- Images are added using image URLs. Device image uploads are not implemented yet.
- Firestore security rules still need to be added before production release.
- The HTTP Cloud Functions API is prepared but not deployed.

## Screenshot checklist

For the school submission, capture:

1. `lib/services/listings_api.dart` showing the GET, POST, PUT, and DELETE methods.
2. Firebase Console showing the `listings` collection and product fields.
3. The app showing the product ListView.
4. The search field showing filtered results.
5. The rarity or availability filter.
6. The Add Listing form and the new product after saving.
7. The edit menu and updated product.
8. The delete confirmation and the product removed from the list.

## Code walkthrough for presentation

The line numbers below refer to the current files. They may change slightly if more code is added later.

### 1. Product model and mapping

File: `lib/listing.dart`, lines 4–31

```dart
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
}
```

Simple explanation: `Listing` is the Dart object used to represent one product. Instead of passing unorganized maps around the app, the product data is stored in a clear object.

File: `lib/listing.dart`, lines 33–51

```dart
factory Listing.fromJson(Map<String, dynamic> json) {
  final createdAtValue = json['createdAt'];

  return Listing(
    id: (json['id'] as num?)?.toInt() ?? 0,
    documentId: json['documentId'] as String? ?? '',
    ownerId: json['ownerId'] as String? ?? '',
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
```

Simple explanation: `fromJson` converts database or API data into a `Listing` object. This is the JSON-to-product mapping feature.

### 2. Reading listings from Firestore

File: `lib/services/firestore_service.dart`, lines 9–19

```dart
Future<List<Listing>> getListings() async {
  final snapshot = await _db.collection('listings').get();

  return snapshot.docs.map((doc) {
    return Listing.fromJson({
      ...doc.data(),
      'documentId': doc.id,
    });
  }).toList();
}
```

Simple explanation: the app opens the `listings` collection, reads all documents, adds the Firestore document ID, converts each document into a `Listing`, and returns a list of products.

### 3. Loading data into the Home page

File: `lib/Home_page.dart`, lines 91–99

```dart
@override
void initState() {
  super.initState();
  _futureListings = _loadListings();
}

Future<LootSwapListings> _loadListings() async {
  final listings = await _firestoreService.getListings();
  return LootSwapListings(data: listings);
}
```

Simple explanation: when the Home page opens, `initState` starts loading the products. `_loadListings` calls the Firestore service and gives the results to the screen.

File: `lib/Home_page.dart`, line 321

```dart
FutureBuilder<LootSwapListings>(
  future: _futureListings,
  builder: (context, snapshot) {
    // The UI is rebuilt when the data finishes loading.
  },
)
```

Simple explanation: `FutureBuilder` displays the loading indicator while waiting, the error message if the request fails, or the products when the request succeeds.

### 4. Search filtering

File: `lib/Home_page.dart`, lines 336–349

```dart
final query = _searchQuery.trim().toLowerCase();
final items = allItems.where((item) {
  final matchesAvailability = !_availableOnly || item.isAvailable;
  final matchesRarity = _selectedRarity == 'All' ||
      item.rarity == _selectedRarity;
  final searchableText =
      '${item.itemName} ${item.category} ${item.rarity} ${item.userName}'
          .toLowerCase();

  return matchesAvailability &&
      matchesRarity &&
      searchableText.contains(query);
}).toList();
```

Simple explanation: the app checks every product and keeps only the products that match the search text, rarity filter, and availability filter.

### 5. Dynamic ListView display

File: `lib/Home_page.dart`, lines 530–538

```dart
ListView.separated(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: items.length,
  separatorBuilder: (context, index) => const SizedBox(height: 12),
  itemBuilder: (context, index) =>
      _buildItemListTile(items[index]),
)
```

Simple explanation: the number of rows is based on the number of products returned by Firestore. If Firestore returns 5 products, the ListView creates 5 product rows.

### 6. Creating a listing

File: `lib/add_listing_page.dart`, lines 44–74

```dart
final user = FirebaseAuth.instance.currentUser;

final listing = Listing(
  id: DateTime.now().millisecondsSinceEpoch,
  ownerId: user.uid,
  userName: user.email?.split('@').first ?? 'User',
  itemName: _itemNameController.text.trim(),
  itemImage: _imageController.text.trim(),
  rarity: _rarity,
  category: _categoryController.text.trim(),
  description: _descriptionController.text.trim(),
  isAvailable: _isAvailable,
  tradeFor: _tradeForController.text.trim(),
);

await _firestoreService.addListing(listing);
```

Simple explanation: the form collects the user's input, creates a `Listing`, saves the current user's UID as `ownerId`, and sends the listing to Firestore.

### 7. Firestore create, update, and delete

File: `lib/services/firestore_service.dart`, lines 22–64

```dart
Future<void> addListing(Listing listing) async {
  await _db.collection('listings').add({
    'ownerId': listing.ownerId,
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

Future<void> updateListing(Listing listing) async {
  await _db.collection('listings').doc(listing.documentId).update({
    'itemName': listing.itemName,
    'itemImage': listing.itemImage,
    'rarity': listing.rarity,
    'category': listing.category,
    'description': listing.description,
    'isAvailable': listing.isAvailable,
    'tradeFor': listing.tradeFor,
  });
}

Future<void> deleteListing(String documentId) async {
  await _db.collection('listings').doc(documentId).delete();
}
```

Simple explanation: `add` creates a new document, `update` changes an existing document, and `delete` removes a document using its Firestore document ID.

### 8. Owner-only editing and deleting

File: `lib/Home_page.dart`, lines 767–771

```dart
bool _canManageListing(Listing item) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  return userId != null &&
      item.ownerId.isNotEmpty &&
      item.ownerId == userId;
}
```

Simple explanation: the menu is shown only when the current signed-in user's UID matches the listing's `ownerId`.

### 9. HTTP API client prepared for later

File: `lib/services/listings_api.dart`, lines 15–53

```dart
Future<List<Listing>> getListings() async {
  final response = await _request('GET', '/listings');
  // Convert the response into Listing objects.
}

Future<Listing> createListing(Listing listing) async {
  final response = await _request('POST', '/listings', body: {...});
}

Future<Listing> updateListing(Listing listing) async {
  final response = await _request('PUT', '/listings/${listing.documentId}',
      body: {...});
}

Future<void> deleteListing(String documentId) async {
  await _request('DELETE', '/listings/$documentId');
}
```

Simple explanation: these methods prepare the four standard HTTP operations. They are not being used by the Home page yet because the Cloud Functions API has not been deployed.

## Questions your teacher may ask

### Why did you use Firestore?

Firestore provides an online database for the products. It allows the app to create, read, update, and delete listings without storing the data only inside the app.

### What is `ownerId` for?

`ownerId` stores the Firebase UID of the user who created the listing. The app uses it to show edit and delete options only to the owner.

### What does `fromJson` do?

It converts map-shaped data from Firestore or an API response into a Dart `Listing` object that Flutter can display.

### How does the search work?

The app compares the typed search text with the item name, category, rarity, and username. Matching products remain in the list.

### How does the ListView become dynamic?

The ListView uses `items.length` for its number of rows. The number of rows changes automatically when the database data or filters change.

### Are the HTTP requests deployed?

No. The Dart HTTP client and Cloud Functions code are prepared, but the app currently uses Firestore directly. Deployment is postponed while development continues.

## Conclusion

LOOTSWAP now has a working Firebase product catalog. Users can view, search, filter, add, edit, and delete game-item listings. The app is still using Firestore directly while we continue developing. The HTTP API is prepared for a later stage when we are ready to install the Firebase CLI and deploy it.
