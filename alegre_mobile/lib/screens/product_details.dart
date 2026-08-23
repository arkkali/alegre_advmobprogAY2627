import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 260.h,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    product.thumbnail,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 64),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            CustomText(
              text: product.title,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: '\$${product.price.toStringAsFixed(2)}',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: 12.h),
            CustomText(text: product.description, fontSize: 14.sp),
            SizedBox(height: 20.h),
            ElevatedButton(
              // Enhancement 3: Add this product using DummyJSON's cart payload.
              onPressed: () async {
                try {
                  await CartService().addProductToCart(
                    userId: 1,
                    productId: product.id,
                    quantity: 1,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product added to cart')),
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unable to add product: $error')),
                  );
                }
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
