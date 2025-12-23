import '../services/api_client.dart';

class MarketplaceService {
  static final ApiClient _apiClient = ApiClient();

  // Mock data for when backend is not available
  static final List<Map<String, dynamic>> _mockProducts = [
    {
      'id': '1',
      'name': 'Premium Stream Overlay Pack',
      'description': 'Professional animated overlay collection with alerts, frames, and transitions.',
      'price': 75,
      'category': 'Digital Assets',
      'inventory': 50,
      'creator': {'name': 'John Doe', 'username': 'john_doe'},
    },
    {
      'id': '2',
      'name': 'Custom Emote Bundle',
      'description': 'Set of 15 custom emotes designed for your community.',
      'price': 45,
      'category': 'Digital Assets',
      'inventory': 30,
      'creator': {'name': 'Jane Smith', 'username': 'jane_smith'},
    },
    {
      'id': '3',
      'name': 'Complete Streaming Setup Guide',
      'description': 'Comprehensive guide covering equipment, software, and best practices.',
      'price': 35,
      'category': 'Education',
      'inventory': 100,
      'creator': {'name': 'Mike Wilson', 'username': 'mike_wilson'},
    },
    {
      'id': '4',
      'name': 'Video Editing Service',
      'description': 'Professional video editing for highlights and promotional content.',
      'price': 95,
      'category': 'Services',
      'inventory': 15,
      'creator': {'name': 'Sarah Jones', 'username': 'sarah_jones'},
    },
    {
      'id': '5',
      'name': 'Royalty-Free Music Pack',
      'description': 'Collection of 50 high-quality background tracks perfect for streaming.',
      'price': 55,
      'category': 'Audio',
      'inventory': 75,
      'creator': {'name': 'Demo Admin', 'username': 'admin'},
    },
  ];

  static final List<Map<String, dynamic>> _mockCategories = [
    {'name': 'Digital Assets', 'count': 2},
    {'name': 'Education', 'count': 1},
    {'name': 'Services', 'count': 1},
    {'name': 'Audio', 'count': 1},
  ];

  static Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    String? sortBy,
  }) async {
    // Always return mock data for now since backend has issues
    var products = List<Map<String, dynamic>>.from(_mockProducts);
    
    // Filter by category if specified
    if (category != null) {
      products = products.where((p) => p['category'] == category).toList();
    }
    
    // Filter by search if specified
    if (search != null) {
      products = products.where((p) => 
        p['name'].toString().toLowerCase().contains(search.toLowerCase()) ||
        p['description'].toString().toLowerCase().contains(search.toLowerCase())
      ).toList();
    }
    
    // Sort products based on sortBy parameter
    if (sortBy != null) {
      switch (sortBy) {
        case 'price_low':
          products.sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
          break;
        case 'price_high':
          products.sort((a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0));
          break;
        case 'oldest':
          products = products.reversed.toList();
          break;
        case 'newest':
        default:
          // Keep original order (newest first)
          break;
      }
    }
    
    return {
      'success': true,
      'data': products,
    };
  }

  static Future<Map<String, dynamic>> getCategories() async {
    return {
      'success': true,
      'data': _mockCategories,
    };
  }

  static Future<Map<String, dynamic>> getFeaturedProducts({int limit = 10}) async {
    return {
      'success': true,
      'data': _mockProducts.take(limit).toList(),
    };
  }

  static Future<Map<String, dynamic>> getProductById(String id) async {
    try {
      final response = await _apiClient.get('/marketplace/products/$id');
      
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        
        if (responseMap['success'] == true && responseMap.containsKey('data')) {
          return {
            'success': true,
            'data': responseMap['data'],
          };
        }
      }
      
      throw Exception('Invalid product response structure');
    } catch (e) {
      // Return mock product when backend is not available
      final mockProduct = _mockProducts.firstWhere(
        (p) => p['id'] == id,
        orElse: () => {},
      );
      
      if (mockProduct.isNotEmpty) {
        return {
          'success': true,
          'data': mockProduct,
        };
      }
      
      return {
        'success': false,
        'message': 'Product not found',
      };
    }
  }

  static Future<Map<String, dynamic>> getCreatorProducts(String creatorId) async {
    try {
      final response = await _apiClient.get('/marketplace/creator/products', queryParameters: {
        'creatorId': creatorId,
      });
      
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        
        if (responseMap['success'] == true && responseMap.containsKey('data')) {
          final data = responseMap['data'];
          
          // Handle double-nested response
          if (data is Map<String, dynamic> && data['success'] == true && data.containsKey('data')) {
            final innerData = data['data'];
            if (innerData is Map<String, dynamic> && innerData.containsKey('products')) {
              return {
                'success': true,
                'data': innerData['products'],
              };
            }
          }
          
          if (data is Map<String, dynamic> && data.containsKey('products')) {
            return {
              'success': true,
              'data': data['products'],
            };
          }
          
          if (data is List) {
            return {
              'success': true,
              'data': data,
            };
          }
        }
      }
      
      throw Exception('Invalid creator products response structure');
    } catch (e) {
      // Return mock products for the creator
      final creatorProducts = _mockProducts.where(
        (p) => p['creator']['username'] == 'creator_$creatorId',
      ).toList();
      
      return {
        'success': true,
        'data': creatorProducts.isNotEmpty ? creatorProducts : _mockProducts.take(2).toList(),
      };
    }
  }

  static Future<Map<String, dynamic>> createOrder(List<Map<String, dynamic>> items) async {
    try {
      final response = await _apiClient.post('/marketplace/orders', data: {
        'items': items,
      });
      
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        
        if (responseMap['success'] == true) {
          return {
            'success': true,
            'data': responseMap['data'],
          };
        }
        
        return {
          'success': false,
          'message': responseMap['message'] ?? 'Failed to create order',
        };
      }
      
      throw Exception('Invalid order response structure');
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating order: $e',
      };
    }
  }

}
