import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/marketplace_service.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MarketplaceService _marketplaceService = MarketplaceService();
  
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _trendingProducts = [];
  List<String> _categories = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMarketplaceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketplaceData() async {
    try {
      final futures = await Future.wait([
        _marketplaceService.getFeaturedProducts(),
        _marketplaceService.getTrendingProducts(),
        _marketplaceService.getCategories(),
      ]);

      setState(() {
        _featuredProducts = futures[0] as List<ProductModel>;
        _trendingProducts = futures[1] as List<ProductModel>;
        _categories = ['All', ...(futures[2] as List<String>)];
        _isLoading = false;
      });

      _loadCartCount();
    } catch (e) {
      print('Error loading marketplace data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCartCount() async {
    try {
      final cartItems = await _marketplaceService.getCart();
      setState(() {
        _cartItemCount = cartItems.length;
      });
    } catch (e) {
      print('Error loading cart count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Marketplace',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black87),
            onPressed: _showSearchDialog,
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.black87),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  ).then((_) => _loadCartCount());
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(text: 'Featured'),
            Tab(text: 'Trending'),
            Tab(text: 'Categories'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFeaturedTab(),
                _buildTrendingTab(),
                _buildCategoriesTab(),
              ],
            ),
    );
  }

  Widget _buildFeaturedTab() {
    return RefreshIndicator(
      onRefresh: _loadMarketplaceData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Featured Products', 'Hand-picked for you'),
            SizedBox(height: 16),
            _buildProductGrid(_featuredProducts),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingTab() {
    return RefreshIndicator(
      onRefresh: _loadMarketplaceData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Trending Now', 'What everyone\'s buying'),
            SizedBox(height: 16),
            _buildProductGrid(_trendingProducts),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return Column(
      children: [
        // Search Bar
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search products...',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              suffixIcon: IconButton(
                icon: Icon(Icons.tune, color: Colors.grey[600]),
                onPressed: _showFilterOptions,
              ),
            ),
            onSubmitted: _performSearch,
          ),
        ),
        
        // Sort Options
        Container(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildSortChip('Popular', Icons.trending_up),
              _buildSortChip('Price: Low to High', Icons.arrow_upward),
              _buildSortChip('Price: High to Low', Icons.arrow_downward),
              _buildSortChip('Newest', Icons.new_releases),
              _buildSortChip('Rating', Icons.star),
            ],
          ),
        ),
        
        // Category Filter
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;
              
              return Padding(
                padding: EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                    _loadCategoryProducts(category);
                  },
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
        ),
        
        Expanded(
          child: _buildCategoryProducts(),
        ),
      ],
    );
  }

  Widget _buildSortChip(String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 16),
        label: Text(label, style: TextStyle(fontSize: 12)),
        onPressed: () => _applySorting(label),
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Price Range
            Text(
              'Price Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            RangeSlider(
              values: RangeValues(0, 100),
              min: 0,
              max: 500,
              divisions: 50,
              labels: RangeLabels('\$0', '\$100'),
              onChanged: (values) {
                // Handle price range change
              },
            ),
            
            SizedBox(height: 20),
            
            // Rating Filter
            Text(
              'Minimum Rating',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    // Handle rating filter
                  },
                  icon: Icon(
                    Icons.star,
                    color: index < 3 ? Colors.amber : Colors.grey[300],
                  ),
                );
              }),
            ),
            
            SizedBox(height: 20),
            
            // Availability
            CheckboxListTile(
              title: Text('In Stock Only'),
              value: true,
              onChanged: (value) {
                // Handle availability filter
              },
            ),
            
            CheckboxListTile(
              title: Text('Free Shipping'),
              value: false,
              onChanged: (value) {
                // Handle shipping filter
              },
            ),
            
            Spacer(),
            
            // Apply Filters Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applySorting(String sortType) {
    // Implement sorting logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sorting by: $sortType')),
    );
  }

  void _applyFilters() {
    // Implement filter logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Filters applied')),
    );
  }

  Widget _buildCategoryProducts() {
    // For demo purposes, show featured products filtered by category
    final filteredProducts = _selectedCategory == 'All'
        ? _featuredProducts
        : _featuredProducts
            .where((product) => product.category == _selectedCategory)
            .toList();

    return RefreshIndicator(
      onRefresh: _loadMarketplaceData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _buildProductGrid(filteredProducts),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No products available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        ).then((_) => _loadCartCount());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[200],
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        ),
                      )
                    : _buildPlaceholderImage(),
              ),
            ),
            
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundImage: product.creator.avatar != null
                              ? NetworkImage(product.creator.avatar!)
                              : null,
                          child: product.creator.avatar == null
                              ? Icon(Icons.person, size: 12)
                              : null,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            product.creator.username,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.creator.verified)
                          Icon(
                            Icons.verified,
                            size: 12,
                            color: Colors.blue,
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

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 48,
        color: Colors.grey[400],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return AlertDialog(
          title: Text('Search Products'),
          content: TextField(
            onChanged: (value) => searchQuery = value,
            decoration: InputDecoration(
              hintText: 'Enter product name...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (searchQuery.isNotEmpty) {
                  _performSearch(searchQuery);
                }
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _performSearch(String query) {
    // TODO: Implement search results screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for: $query')),
    );
  }

  Future<void> _loadCategoryProducts(String category) async {
    // TODO: Load products by category
    print('Loading products for category: $category');
  }
}