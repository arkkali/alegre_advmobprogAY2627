import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';

class CartService {
  Future<Cart> getCartByUserId(int userId) async {
    final response = await http.get(Uri.parse('$host/carts/user/$userId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load cart for user $userId');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final carts = (data['carts'] as List?) ?? [];
    if (carts.isEmpty) {
      throw Exception('No cart found for user $userId');
    }
    return Cart.fromJson(carts.first as Map<String, dynamic>);
  }

  // Enhancement 3: Retrieve one cart directly by its cart ID.
  Future<Cart> getCartById(int cartId) async {
    final response = await http.get(Uri.parse('$host/carts/$cartId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load cart $cartId');
    }
    return Cart.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Enhancement 3: Add a product with the API's userId/products payload.
  Future<Cart> addProductToCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse('$host/carts/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'products': [
          {'id': productId, 'quantity': quantity},
        ],
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add product to cart');
    }
    return Cart.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
