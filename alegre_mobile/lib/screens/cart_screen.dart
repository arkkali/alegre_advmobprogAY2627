import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'product_details.dart';

class CartScreen extends StatefulWidget {
  final int userId;

  const CartScreen({super.key, this.userId = 1});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<Cart> _cartFuture;
  final Map<int, int> _quantities = {};
  final Set<int> _removedProductIds = {};

  @override
  void initState() {
    super.initState();
    _cartFuture = CartService().getCartByUserId(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<Cart>(
      future: _cartFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: CustomText(
              text: 'Error loading cart: ${snapshot.error}',
              fontSize: 14.sp,
            ),
          );
        }

        final cart = snapshot.data!;
        final visibleProducts = cart.products
            .where((product) => !_removedProductIds.contains(product.id))
            .toList();
        for (final product in visibleProducts) {
          _quantities.putIfAbsent(product.id, () => product.quantity);
        }
        final subtotal = visibleProducts.fold<double>(
          0,
          (sum, product) =>
              sum +
              product.price * (_quantities[product.id] ?? product.quantity),
        );
        final deliveryFee = 0.0;
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _cartFuture = CartService().getCartByUserId(widget.userId);
            });
            await _cartFuture;
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 20.h),
            children: [
              if (visibleProducts.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _emptyCart(context),
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Empty cart'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                  ),
                ),
              if (visibleProducts.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 70.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.remove_shopping_cart_outlined,
                        size: 54.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: 12.h),
                      CustomText(
                        text: 'Your cart is empty',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ...visibleProducts.map(
                (product) => _CartItem(
                  product: product,
                  quantity: _quantities[product.id] ?? product.quantity,
                  onQuantityChanged: (quantity) {
                    setState(() => _quantities[product.id] = quantity);
                  },
                  onRemove: () {
                    setState(() => _removedProductIds.add(product.id));
                  },
                ),
              ),
              SizedBox(height: 16.h),
              _SummaryRow(label: 'Subtotal:', value: subtotal),
              SizedBox(height: 8.h),
              _SummaryRow(label: 'Delivery Fee:', value: deliveryFee),
              SizedBox(height: 14.h),
              SizedBox(
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order confirmation coming soon'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: CustomText(
                    text: 'Confirm Order',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _emptyCart(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Empty cart?'),
        content: const Text('Remove all products from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Empty cart'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final cart = await _cartFuture;
    if (!mounted) return;
    setState(() {
      _removedProductIds.addAll(cart.products.map((product) => product.id));
    });
  }
}

class _CartItem extends StatelessWidget {
  final CartProduct product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItem({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.r),
        // Enhancement 1: Cart items reuse the shared product detail screen.
        onTap: () async {
          try {
            final fullProduct = await ProductService().getProductById(
              product.id,
            );
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(product: fullProduct),
              ),
            );
          } catch (error) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unable to open product: $error')),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Row(
            children: [
              SizedBox(
                width: 76.w,
                height: 76.h,
                child: Image.network(
                  product.thumbnail,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: product.title,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    CustomText(
                      text: '\$${product.price.toStringAsFixed(2)}',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      text:
                          '${product.discountPercentage.toStringAsFixed(0)}% off • \$${product.total.toStringAsFixed(2)} total',
                      fontSize: 10.sp,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                children: [
                  _QuantityButton(
                    icon: Icons.delete_outline,
                    onPressed: onRemove,
                    muted: true,
                  ),
                  SizedBox(height: 5.h),
                  _QuantityButton(
                    icon: Icons.add,
                    onPressed: () => onQuantityChanged(quantity + 1),
                  ),
                  SizedBox(height: 5.h),
                  CustomText(
                    text: '$quantity',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 5.h),
                  _QuantityButton(
                    icon: Icons.remove,
                    onPressed: quantity > 1
                        ? () => onQuantityChanged(quantity - 1)
                        : null,
                    muted: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool muted;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 30.w,
      height: 30.h,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: muted
              ? colorScheme.surfaceContainerHighest
              : colorScheme.primary,
          foregroundColor: muted
              ? colorScheme.onSurfaceVariant
              : colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9.r),
          ),
        ),
        icon: Icon(icon, size: 17.sp),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(text: label, fontSize: 12.sp),
        CustomText(
          text: '\$${value.toStringAsFixed(2)}',
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }
}
