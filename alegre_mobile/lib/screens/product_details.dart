import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  Widget _buildSectionHeader(String title) {
    return CustomText(
      text: title,
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
    );
  }

  Widget _buildInfoPill(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: Colors.blueGrey),
          SizedBox(width: 6.w),
          CustomText(
            text: text,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Map<int, int> _buildRatingDistribution(List<ProductReview> reviews) {
    final distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (final review in reviews) {
      if (review.rating >= 1 && review.rating <= 5) {
        distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
      }
    }

    return distribution;
  }

  Widget _buildRatingSummaryCard(
    Product product,
    List<ProductReview> reviews,
    double ratingAverage,
  ) {
    final distribution = _buildRatingDistribution(reviews);
    final totalReviews = reviews.length;
    final maxCount = distribution.values.fold<int>(0, (currentMax, count) {
      return count > currentMax ? count : currentMax;
    });

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade50, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 28.sp, color: Colors.amber),
                        SizedBox(width: 8.w),
                        CustomText(
                          text: ratingAverage.toStringAsFixed(1),
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    CustomText(
                      text: totalReviews == 0
                          ? 'No customer reviews yet'
                          : '$totalReviews verified customer reviews',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: CustomText(
                  text: '${product.rating.toStringAsFixed(1)} / 5',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (totalReviews > 0)
            ...List.generate(5, (index) {
              final star = 5 - index;
              final count = distribution[star] ?? 0;
              final ratio = maxCount == 0 ? 0.0 : count / maxCount;

              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    CustomText(
                      text: '$star',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.star_rounded, size: 14.sp, color: Colors.amber),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Container(
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: ratio,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 26.w,
                      child: CustomText(
                        text: '$count',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            })
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: CustomText(
                text: 'Be the first to leave a review for this product.',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: Colors.blueGrey),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: label,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: value,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ProductReview review) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  text: review.reviewerName,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              CustomText(
                text: review.date,
                fontSize: 10.sp,
                color: Colors.grey,
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                size: 16.sp,
                color: Colors.amber,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: review.comment,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageList = product.images.isNotEmpty ? product.images : [product.thumbnail];
    final reviews = product.reviews;
    final ratingAverage = reviews.isNotEmpty
        ? reviews.map((review) => review.rating).reduce((a, b) => a + b) / reviews.length
        : product.rating;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 260.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageList.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    final imageUrl = imageList[index];
                    return Container(
                      width: 0.78.sw,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image, size: 64)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: product.title,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: 18.sp, color: Colors.amber),
                            SizedBox(width: 6.w),
                            CustomText(
                              text: ratingAverage.toStringAsFixed(1),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            SizedBox(width: 8.w),
                            CustomText(
                              text: '${reviews.length} reviews',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: CustomText(
                      text: '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomText(
                    text: '\$${product.price.toStringAsFixed(2)}',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                  ),
                  SizedBox(width: 10.w),
                  CustomText(
                    text: product.availabilityStatus,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _buildInfoPill(product.brand, Icons.storefront_outlined),
                  _buildInfoPill('Free Shipping', Icons.local_shipping_outlined),
                  _buildInfoPill('In Stock: ${product.stock}', Icons.inventory_2_outlined),
                  _buildInfoPill(product.category, Icons.category_outlined),
                  _buildInfoPill('2-Year Warranty', Icons.shield_outlined),
                  _buildInfoPill('30-Day Returns', Icons.assignment_return_outlined),
                ],
              ),
              SizedBox(height: 18.h),
              _buildSectionHeader('Description'),
              SizedBox(height: 8.h),
              CustomText(
                text: product.description,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
              SizedBox(height: 18.h),
              _buildSectionHeader('Popular Tags'),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: product.tags.isEmpty
                    ? [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: CustomText(
                            text: 'No tags available',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]
                    : product.tags
                        .map(
                          (tag) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: CustomText(
                              text: tag,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
              ),
              SizedBox(height: 18.h),
              _buildSectionHeader('Product Details'),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.shield_outlined, 'Warranty', product.warrantyInformation),
                    Divider(),
                    _buildDetailRow(Icons.local_shipping_outlined, 'Shipping', product.shippingInformation),
                    Divider(),
                    _buildDetailRow(Icons.assignment_return_outlined, 'Return Policy', product.returnPolicy),
                    Divider(),
                    _buildDetailRow(Icons.qr_code_2_outlined, 'SKU', product.sku),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              _buildSectionHeader('Ratings & Reviews'),
              SizedBox(height: 10.h),
              _buildRatingSummaryCard(product, reviews, ratingAverage),
              SizedBox(height: 18.h),
              _buildSectionHeader('Customer Reviews'),
              SizedBox(height: 10.h),
              if (reviews.isNotEmpty)
                ...reviews.take(3).map((review) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _buildReviewCard(review),
                    ))
              else
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: CustomText(
                    text: 'No reviews yet for this product.',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
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
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
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
