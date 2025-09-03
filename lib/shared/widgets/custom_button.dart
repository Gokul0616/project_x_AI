import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/utils/responsive_utils.dart';
import 'package:project_x/core/providers/theme_provider.dart';

enum ButtonType { primary, secondary, outline, text }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? customChild;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.customChild,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final buttonStyle = _getButtonStyle(context, isDark);
        final textStyle = _getTextStyle(isDark);
        final padding = _getPadding(context);

        Widget child = customChild ?? _buildButtonContent(textStyle);

        if (isLoading) {
          child = SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ButtonType.primary ? AppColors.white : AppColors.blue,
              ),
            ),
          );
        }

        Widget button;

        switch (type) {
          case ButtonType.primary:
            button = ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: child,
            );
            break;
          case ButtonType.secondary:
            button = ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: child,
            );
            break;
          case ButtonType.outline:
            button = OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: child,
            );
            break;
          case ButtonType.text:
            button = TextButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: child,
            );
            break;
        }

        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: button,
        );
      },
    );
  }

  Widget _buildButtonContent(TextStyle textStyle) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          Text(text, style: textStyle),
        ],
      );
    }
    return Text(text, style: textStyle);
  }

  ButtonStyle _getButtonStyle(BuildContext context, bool isDark) {
    final padding = _getPadding(context);
    final borderRadius = BorderRadius.circular(_getBorderRadius());

    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.blueDisabled,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 0,
        );
      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkGray,
          foregroundColor: AppColors.textPrimary(isDark),
          disabledBackgroundColor: AppColors.darkGray.withOpacity(0.5),
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 0,
        );
      case ButtonType.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue,
          side: const BorderSide(color: AppColors.blue, width: 1),
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );
      case ButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: AppColors.blue,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );
    }
  }

  TextStyle _getTextStyle(bool isDark) {
    TextStyle baseStyle;
    switch (size) {
      case ButtonSize.small:
        baseStyle = TextStyles.buttonSmall;
        break;
      case ButtonSize.medium:
        baseStyle = TextStyles.buttonMedium;
        break;
      case ButtonSize.large:
        baseStyle = TextStyles.buttonLarge;
        break;
    }

    Color color = AppColors.white;
    switch (type) {
      case ButtonType.primary:
        color = AppColors.white;
        break;
      case ButtonType.secondary:
        color = AppColors.textPrimary(isDark);
        break;
      case ButtonType.outline:
      case ButtonType.text:
        color = AppColors.blue;
        break;
    }

    return baseStyle.copyWith(color: color);
  }

  EdgeInsets _getPadding(BuildContext context) {
    double horizontal, vertical;
    
    switch (size) {
      case ButtonSize.small:
        horizontal = ResponsiveUtils.isMobile(context) ? 12 : 16;
        vertical = 8;
        break;
      case ButtonSize.medium:
        horizontal = ResponsiveUtils.isMobile(context) ? 16 : 20;
        vertical = 12;
        break;
      case ButtonSize.large:
        horizontal = ResponsiveUtils.isMobile(context) ? 20 : 24;
        vertical = 16;
        break;
    }

    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  double _getBorderRadius() {
    switch (size) {
      case ButtonSize.small:
        return 20;
      case ButtonSize.medium:
        return 24;
      case ButtonSize.large:
        return 28;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }
}