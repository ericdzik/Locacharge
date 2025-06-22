import 'package:flutter/material.dart';
import 'package:locacharge/shared/styles/colors.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final double borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showShadow;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.onTap,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: AppColors.grey200.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.grey200.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class ModernCardWithGradient extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const ModernCardWithGradient({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
