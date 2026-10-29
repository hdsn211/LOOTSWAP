import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
 

class ExampleDestination {
  const ExampleDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

// ============================================================
// NAVIGATION DESTINATIONS
// ============================================================

const List<ExampleDestination> destinations = <ExampleDestination>[
  ExampleDestination(
    'Discover',
    Icon(Icons.explore_outlined),
    Icon(Icons.explore),
  ),
  ExampleDestination(
    'Matches',
    Icon(Icons.favorite_border),
    Icon(Icons.favorite),
  ),
  ExampleDestination(
    'Messages',
    Icon(Icons.chat_bubble_outline),
    Icon(Icons.chat_bubble),
  ),
  ExampleDestination(
    'Likes',
    Icon(Icons.favorite_border_outlined),
    Icon(Icons.favorite),
  ),
  ExampleDestination('Profile', Icon(Icons.person_outline), Icon(Icons.person)),
  ExampleDestination(
    'Settings',
    Icon(Icons.settings_outlined),
    Icon(Icons.settings),
  ),
];

class LootSwapListings {
  const LootSwapListings({required this.data});

  final List<Listing> data;

  factory LootSwapListings.fromJson(Map<String, dynamic> json) {
    return LootSwapListings(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => Listing.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

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
      id: json['id'] as int? ?? 0,
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

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// ============================================================
// HOME PAGE STATE
// ============================================================

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  int screenIndex = 0;
  bool _availableOnly = false;
  String _searchQuery = '';
  String _selectedRarity = 'All';
  late Future<LootSwapListings> _futureListings;

  @override
  void initState() {
    super.initState();
    _futureListings = _loadListings();
  }

  Future<LootSwapListings> _loadListings() async {
    final response = await http.get(
      Uri.parse(
        'https://raw.githubusercontent.com/hdsn211/items/refs/heads/main/listings.json',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load listings (HTTP ${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return LootSwapListings.fromJson(decoded);
  }

  // ==========================================================
  // LOOTSWAP COLOR PALETTE
  // ==========================================================

  static const String appName = 'LOOTSWAP';
  static const String tagline = "Don't Need It? Swap It!";

  static const Color backgroundColor = Color(0xFF101116);
  static const Color cardColor = Color(0xFF1C1D25);
  static const Color secondarySurfaceColor = Color(0xFF242530);
  static const Color purpleColor = Color(0xFF4338FF);
  static const Color primaryTextColor = Color(0xFFF5F5FA);
  static const Color secondaryTextColor = Color(0xFF898B99);
  static const Color darkTeal = secondarySurfaceColor;

  // ==========================================================
  // SCREEN CHANGE
  // ==========================================================

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      screenIndex = selectedScreen;
    });

    Navigator.pop(context);
  }

  // ==========================================================
  // SNACKBAR
  // ==========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        backgroundColor: darkTeal,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'User';

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: Drawer(
        width: 280,
        backgroundColor: cardColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    appName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: primaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ...[
                  {'label': 'Dashboard', 'icon': Icons.dashboard_outlined},
                  {'label': 'My Trades', 'icon': Icons.swap_horiz_outlined},
                  {'label': 'My Items', 'icon': Icons.inventory_2_outlined},
                  {'label': 'Profile', 'icon': Icons.person_outline},
                  {'label': 'Settings', 'icon': Icons.settings_outlined},
                ].map((item) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: Icon(
                      item['icon'] as IconData,
                      color: secondaryTextColor,
                      size: 22,
                    ),
                    title: Text(
                      item['label'] as String,
                      style: GoogleFonts.poppins(
                        color: primaryTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  );
                }),
                const Spacer(),
                const Divider(color: Colors.white12),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: const Icon(Icons.logout, color: secondaryTextColor),
                  title: Text(
                    'Sign Out',
                    style: GoogleFonts.poppins(
                      color: primaryTextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          icon: const Icon(Icons.menu, color: primaryTextColor),
                          splashRadius: 22,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appName,
                        style: GoogleFonts.poppins(
                          color: primaryTextColor,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 130),
                            child: Text(
                              userEmail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                                color: secondaryTextColor,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Notifications',
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: FutureBuilder<LootSwapListings>(
                      future: _futureListings,
                      builder: (context, snapshot) {
                        final allItems =
                            snapshot.data?.data ?? const <Listing>[];
                        final availableCount = allItems
                            .where((item) => item.isAvailable)
                            .length;
                        final rarities =
                            allItems
                                .map((item) => item.rarity)
                                .where((rarity) => rarity.isNotEmpty)
                                .toSet()
                                .toList()
                              ..sort();
                        final query = _searchQuery.trim().toLowerCase();
                        final items = allItems.where((item) {
                          final matchesAvailability =
                              !_availableOnly || item.isAvailable;
                          final matchesRarity =
                              _selectedRarity == 'All' ||
                              item.rarity == _selectedRarity;
                          final searchableText =
                              '${item.itemName} ${item.category} ${item.rarity} ${item.userName}'
                                  .toLowerCase();
                          return matchesAvailability &&
                              matchesRarity &&
                              searchableText.contains(query);
                        }).toList();

                        return Column(
                          children: [
                            Row(
                              children: [
                                _buildInventoryTab(
                                  label: 'Featured',
                                  count: allItems.length,
                                  selected: !_availableOnly,
                                  onTap: () => setState(() {
                                    _availableOnly = false;
                                  }),
                                ),
                                const SizedBox(width: 8),
                                _buildInventoryTab(
                                  label: 'Available',
                                  count: availableCount,
                                  selected: _availableOnly,
                                  onTap: () => setState(() {
                                    _availableOnly = true;
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.06,
                                        ),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (value) => setState(() {
                                        _searchQuery = value;
                                      }),
                                      style: GoogleFonts.poppins(
                                        color: primaryTextColor,
                                        fontSize: 13,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Search inventory',
                                        hintStyle: GoogleFonts.poppins(
                                          color: secondaryTextColor,
                                          fontSize: 13,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: secondaryTextColor,
                                          size: 20,
                                        ),
                                        suffixIcon: _searchQuery.isEmpty
                                            ? null
                                            : IconButton(
                                                tooltip: 'Clear search',
                                                onPressed: () {
                                                  _searchController.clear();
                                                  setState(() {
                                                    _searchQuery = '';
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.close,
                                                  size: 18,
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 11,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  tooltip: 'Filter by rarity',
                                  initialValue: _selectedRarity,
                                  onSelected: (rarity) => setState(() {
                                    _selectedRarity = rarity;
                                  }),
                                  color: secondarySurfaceColor,
                                  icon: const Icon(
                                    Icons.tune_rounded,
                                    color: secondaryTextColor,
                                  ),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'All',
                                      child: Text(
                                        'All rarities',
                                        style: TextStyle(
                                          color: primaryTextColor,
                                        ),
                                      ),
                                    ),
                                    ...rarities.map(
                                      (rarity) => PopupMenuItem(
                                        value: rarity,
                                        child: Text(
                                          rarity,
                                          style: const TextStyle(
                                            color: primaryTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildPromoBanner(),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Featured Items',
                                            style: GoogleFonts.poppins(
                                              color: primaryTextColor,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${items.length} items',
                                          style: GoogleFonts.poppins(
                                            color: secondaryTextColor,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting)
                                      const SizedBox(
                                        height: 160,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: purpleColor,
                                          ),
                                        ),
                                      )
                                    else if (snapshot.hasError)
                                      _buildListingsMessage(
                                        'Unable to load items. Please try again.',
                                        action: TextButton(
                                          onPressed: () => setState(() {
                                            _futureListings = _loadListings();
                                          }),
                                          child: const Text('Retry'),
                                        ),
                                      )
                                    else if (items.isEmpty)
                                      _buildListingsMessage(
                                        query.isEmpty &&
                                                _selectedRarity == 'All'
                                            ? 'No featured items available.'
                                            : 'No items match these filters.',
                                      )
                                    else
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final wideLayout =
                                              MediaQuery.of(
                                                context,
                                              ).size.width >
                                              720;
                                          return GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: items.length,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: wideLayout
                                                      ? 3
                                                      : 2,
                                                  crossAxisSpacing: 12,
                                                  mainAxisSpacing: 12,
                                                  childAspectRatio: wideLayout
                                                      ? 0.9
                                                      : 0.7,
                                                ),
                                            itemBuilder: (context, index) =>
                                                _buildItemCard(items[index]),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.swap_horiz_rounded,
                color: secondaryTextColor,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to trade?',
                      style: GoogleFonts.poppins(
                        color: primaryTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Browse player listings',
                      style: GoogleFonts.poppins(
                        color: secondaryTextColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () => _showMessage('Trade selected!'),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 17),
                  label: Text(
                    'Trade',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purpleColor,
                    foregroundColor: primaryTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryTab({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: selected ? secondarySurfaceColor : cardColor,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: selected
                    ? purpleColor
                    : Colors.white.withValues(alpha: 0.04),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: selected ? primaryTextColor : secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? purpleColor : cardColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.poppins(
                      color: primaryTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      height: 142,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF242530), Color(0xFF171827), Color(0xFF3125A8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 12,
            top: 8,
            bottom: 8,
            child: Icon(
              Icons.sports_esports_rounded,
              size: 112,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'YOUR NEXT LOOT\nIS OUT THERE',
                  style: GoogleFonts.poppins(
                    color: primaryTextColor,
                    fontSize: 18,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  tagline,
                  style: GoogleFonts.poppins(
                    color: secondaryTextColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsMessage(String message, {Widget? action}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: secondaryTextColor, fontSize: 12),
          ),
          ?action,
        ],
      ),
    );
  }

  Widget _buildItemCard(Listing item) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showMessage('${item.itemName} selected!'),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: item.itemImage.trim().isEmpty
                      ? _buildItemImagePlaceholder()
                      : Image.network(
                          item.itemImage,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildItemImagePlaceholder(),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return _buildItemImagePlaceholder(loading: true);
                          },
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.itemName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: primaryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${item.rarity} • ${item.category}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: secondaryTextColor,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.tradeFor.isEmpty
                    ? 'Open to offers'
                    : 'Wants: ${item.tradeFor}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFB7B2FF),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 7),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () => _showMessage('${item.itemName} selected!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purpleColor,
                    foregroundColor: primaryTextColor,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'View item',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemImagePlaceholder({bool loading = false}) {
    return Container(
      width: double.infinity,
      color: secondarySurfaceColor,
      child: Center(
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: purpleColor,
                ),
              )
            : Icon(
                Icons.inventory_2_outlined,
                size: 36,
                color: secondaryTextColor.withValues(alpha: 0.7),
              ),
      ),
    );
  }
}
