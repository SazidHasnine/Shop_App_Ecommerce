import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_app_ecommerce/core/constants/app_colors.dart';
import 'package:shop_app_ecommerce/features/order/models/payment_method_model.dart';

class PaymentOption extends StatelessWidget {
  const PaymentOption({
    super.key,
    required this.method,
    required this.isDark,
    required this.currentSelection,
    required this.onSelect,
  });

  final PaymentMethod method;
  final bool isDark;
  final PaymentMethod currentSelection;
  final Function(PaymentMethod) onSelect;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentSelection == method;

    return InkWell(
      onTap: () => onSelect(method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              method.icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 14,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected
                          ? (isDark ? Colors.white : AppColors.primary)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2,),
                  Text(
                    method.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
