import 'package:flutter/material.dart';
import 'package:locacharge/shared/styles/colors.dart';

class ModernTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;

  const ModernTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  bool _isFocused = false;
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: TextStyle(
                color: _isFocused
                    ? AppColors.primaryColor
                    : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isFocused
                    ? AppColors.primaryColor
                    : widget.errorText != null
                        ? AppColors.errorColor
                        : AppColors.grey200,
                width: _isFocused ? 2 : 1.5,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: _isObscured,
              enabled: widget.enabled,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              validator: widget.validator,
              onChanged: widget.onChanged,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? AppColors.primaryColor
                            : AppColors.textLight,
                        size: 20,
                      )
                    : null,
                suffixIcon: widget.suffixIcon != null || widget.obscureText
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.obscureText)
                            IconButton(
                              icon: Icon(
                                _isObscured
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.textLight,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            ),
                          if (widget.suffixIcon != null)
                            IconButton(
                              icon: Icon(
                                widget.suffixIcon,
                                color: AppColors.textLight,
                                size: 20,
                              ),
                              onPressed: widget.onSuffixIconTap,
                            ),
                        ],
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          if (widget.errorText != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.errorColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.errorText!,
                  style: TextStyle(
                    color: AppColors.errorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ModernSearchField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const ModernSearchField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint ?? 'Rechercher...',
          hintStyle: TextStyle(
            color: AppColors.textLight,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textLight,
            size: 20,
          ),
          suffixIcon: controller?.text.isNotEmpty == true
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
