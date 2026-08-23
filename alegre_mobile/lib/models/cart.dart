class Cart {
  final int id;
  final List<CartProduct> products;
  final double total;
  final double discountedTotal;
  final int userId;
  final int totalProducts;
  final int totalQuantity;

  Cart({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as int? ?? 0,
      products:
          (json['products'] as List?)
              ?.map(
                (item) => CartProduct.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      total: (json['total'] as num?)?.toDouble() ?? 0,
      discountedTotal: (json['discountedTotal'] as num?)?.toDouble() ?? 0,
      userId: json['userId'] as int? ?? 0,
      totalProducts: json['totalProducts'] as int? ?? 0,
      totalQuantity: json['totalQuantity'] as int? ?? 0,
    );
  }
}

class CartProduct {
  final int id;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final double discountPercentage;
  final double discountedTotal;
  final String thumbnail;

  CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedTotal,
    required this.thumbnail,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] as int? ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      discountedTotal: (json['discountedTotal'] as num?)?.toDouble() ?? 0,
      thumbnail: json['thumbnail'] as String? ?? '',
    );
  }
}
