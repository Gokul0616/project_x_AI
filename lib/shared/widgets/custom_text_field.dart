import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/providers/theme_provider.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final String? errorText;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? Function(String?)? validator; // New validator parameter

  const CustomTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.errorText,
    this.autofocus = false,
    this.focusNode,
    this.validator, // Add the validator parameter
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.labelText != null) ...[
              Text(
                widget.labelText!,
                style: TextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: _isFocused ? AppColors.blue : AppColors.textSecondary(isDark),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkGray,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.errorText != null
                      ? AppColors.error
                      : _isFocused
                      ? AppColors.blue
                      : AppColors.borderColor(isDark),
                  width: _isFocused ? 2 : 1,
                ),
              ),
              child: TextFormField(
                // Change TextField to TextFormField for validation
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted, // Set onFieldSubmitted
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                style: TextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary(isDark),
                  ),
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  counterText: '',
                ),
                validator:
                    widget.validator, // Use the validator passed to the widget
              ),
            ),
            if (widget.errorText != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.errorText!,
                      style: TextStyles.bodySmall.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}