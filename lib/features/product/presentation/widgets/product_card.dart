import 'package:flutter/material.dart';
import 'package:shop_app_ecommerce/core/constants/app_colors.dart';
import 'package:shop_app_ecommerce/core/widgets/custom_cached_image.dart';
import 'package:shop_app_ecommerce/features/product/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // thumbnail
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  color: isDark ? Colors.black26 : Colors.grey.shade100,
                  child: CustomCachedImage(
                    imageUrl: product.thumbnail,
                    fit: BoxFit.cover,
                    iconSize: 40,
                  ),
                ),
              ),
              if(product.rating > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: ,
                      borderRadius: ,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // details
        Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.category.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark
                       ? AppColors.primaryLight
                       : AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4,),
              Text(
                product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$${product.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  InkWell(
                    onTap: () {

                    },
                    borderRadius: ,
                    child: ,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
