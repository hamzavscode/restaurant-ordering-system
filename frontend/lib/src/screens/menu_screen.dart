import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart' as models;
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/item_detail_sheet.dart';
import '../widgets/menu_shimmer.dart';

/// Menu Screen - Displays the restaurant menu with categories and search.
/// Fetches data from GET /api/elements and displays items in a grid.
class MenuScreen extends StatefulWidget {
  final String userName;

  const MenuScreen({super.key, required this.userName});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Map<String, dynamic>> _allItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  // Cart is now managed globally by CartProvider
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();

  final List<String> _categories = ['All', 'Food', 'Drinks', 'Desserts'];

  // Map backend type_element values to category names
  final Map<String, String> _typeToCategory = {
    'PLAT': 'Food',
    'BOISSON': 'Drinks',
    'DESSERT': 'Desserts',
  };

  // Local demo images based on type
  final Map<String, String> _categoryImages = {
    'PLAT': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
    'BOISSON': 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400',
    'DESSERT': 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400',
  };

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMenu() async {
    try {
      final items = await ApiService.getMenu();
      setState(() {
        _allItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> result = _allItems;

    // Filter by category
    if (_selectedCategory != 'All') {
      result = result.where((item) {
        final type = item['type_element'] ?? '';
        return _typeToCategory[type] == _selectedCategory;
      }).toList();
    }

    // Filter by search
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where(
              (item) => (item['nom'] ?? '').toString().toLowerCase().contains(query))
          .toList();
    }

    _filteredItems = result;
  }

  void _addToCart(Map<String, dynamic> item, [int quantity = 1]) {
    final menuItem = models.MenuItem.fromJson(item);
    context.read<CartProvider>().addItem(menuItem, quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['nom']} x$quantity ajouté au panier'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showItemDetail(Map<String, dynamic> item) {
    showItemDetail(
      context,
      item,
      _getImageForItem(item),
      (selectedItem, quantity) => _addToCart(selectedItem, quantity),
    );
  }

  String _getImageForItem(Map<String, dynamic> item) {
    if (item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty) {
      return item['imageUrl'];
    }
    final type = item['type_element'] ?? 'PLAT';
    return _categoryImages[type] ?? _categoryImages['PLAT']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Header ───
            _buildHeader(),

            // ─── Scrollable Content ───
            Expanded(
              child: _isLoading
                  ? const MenuShimmer()
                  : RefreshIndicator(
                      onRefresh: _loadMenu,
                      color: AppTheme.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildSearchBar(),
                            const SizedBox(height: 16),
                            _buildCategoryTabs(),
                            const SizedBox(height: 20),
                            _buildMenuGrid(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top header with logo, greeting, and profile avatar.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Logo Row ───
          Row(
            children: [
              Icon(Icons.restaurant, color: AppTheme.primary, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Modern Hospitality',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              const Spacer(),
              // ─── Profile Avatar ───
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primaryFaded.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: AppTheme.primary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Greeting ───
          Text(
            'Hello, ${widget.userName} 👋',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'What would you like to order today?',
            style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  /// Search bar widget.
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() => _applyFilters());
      },
      style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
      decoration: InputDecoration(
        hintText: 'Search for dishes...',
        hintStyle: TextStyle(color: AppTheme.textMuted.withOpacity(0.6)),
        prefixIcon:
            const Icon(Icons.search, color: AppTheme.textMuted, size: 22),
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Horizontal category filter tabs.
  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return GestureDetector(
            onTap: () => _filterByCategory(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(color: AppTheme.textMuted.withOpacity(0.2)),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Grid of menu item cards.
  Widget _buildMenuGrid() {
    if (_filteredItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.restaurant_menu, size: 60, color: AppTheme.textMuted),
              SizedBox(height: 12),
              Text(
                'Aucun plat trouvé',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        return _buildMenuCard(_filteredItems[index]);
      },
    );
  }

  /// Single menu item card.
  Widget _buildMenuCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _showItemDetail(item),
      child: Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Item Image ───
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              _getImageForItem(item),
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                color: AppTheme.primaryFaded.withOpacity(0.2),
                child: const Icon(Icons.restaurant,
                    size: 40, color: AppTheme.primary),
              ),
            ),
          ),

          // ─── Item Info ───
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    item['nom'] ?? 'Sans nom',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const Spacer(),

                  // ─── Price + Add Button ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(item['prix'] ?? 0).toStringAsFixed(0)} DH',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(item),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
