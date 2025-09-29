import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum CustomButtonVariant { primary, secondary, outline, ghost, danger }

enum CustomButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final CustomButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.size = CustomButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height,
  });

  // Size configurations
  static const Map<CustomButtonSize, EdgeInsets> _paddingMap = {
    CustomButtonSize.small: EdgeInsets.symmetric(
      horizontal: kSpacingLG,
      vertical: kSpacingSM,
    ),
    CustomButtonSize.medium: EdgeInsets.symmetric(
      horizontal: kSpacingXL,
      vertical: kSpacingMD,
    ),
    CustomButtonSize.large: EdgeInsets.symmetric(
      horizontal: kSpacingXXL,
      vertical: kSpacingLG,
    ),
  };

  static const Map<CustomButtonSize, double> _fontSizeMap = {
    CustomButtonSize.small: FontSizes.sm,
    CustomButtonSize.medium: FontSizes.sm,
    CustomButtonSize.large: FontSizes.base,
  };

  static const Map<CustomButtonSize, double> _iconSizeMap = {
    CustomButtonSize.small: 16,
    CustomButtonSize.medium: 18,
    CustomButtonSize.large: 20,
  };

  // Get button colors based on variant
  Color _getBackgroundColor() {
    switch (variant) {
      case CustomButtonVariant.primary:
        return AppColors.primary;
      case CustomButtonVariant.secondary:
        return AppColors.secondary;
      case CustomButtonVariant.outline:
      case CustomButtonVariant.ghost:
        return Colors.transparent;
      case CustomButtonVariant.danger:
        return AppColors.error;
    }
  }

  Color _getForegroundColor() {
    return AppColors.textPrimary;
  }

  BorderSide? _getBorderSide() {
    if (variant == CustomButtonVariant.outline) {
      return BorderSide(color: AppColors.surfaceLight, width: 1);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isButtonDisabled = isDisabled || isLoading || onPressed == null;

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null && !isLoading)
          Padding(
            padding: const EdgeInsets.only(right: kSpacingXS),
            child: Icon(leadingIcon, size: _iconSizeMap[size]),
          ),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(right: kSpacingXS),
            child: SizedBox(
              width: _iconSizeMap[size],
              height: _iconSizeMap[size],
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  variant == CustomButtonVariant.outline ||
                          variant == CustomButtonVariant.ghost
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        Text(
          isLoading ? 'Loading...' : text,
          style: TextStyle(
            fontSize: _fontSizeMap[size],
            fontWeight: FontWeights.medium,
            height: 1.2,
          ),
        ),
        if (trailingIcon != null && !isLoading)
          Padding(
            padding: const EdgeInsets.only(left: kSpacingXS),
            child: Icon(trailingIcon, size: _iconSizeMap[size]),
          ),
      ],
    );

    // Choose button type based on variant
    switch (variant) {
      case CustomButtonVariant.outline:
        return OutlinedButton(
          onPressed: isButtonDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: _getBackgroundColor(),
            foregroundColor: _getForegroundColor(),
            padding: _paddingMap[size],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusMD),
            ),
            side: _getBorderSide(),
            minimumSize: Size(width ?? 0, height ?? 0),
          ),
          child: buttonChild,
        );

      case CustomButtonVariant.ghost:
        return TextButton(
          onPressed: isButtonDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            backgroundColor: _getBackgroundColor(),
            foregroundColor: _getForegroundColor(),
            padding: _paddingMap[size],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusMD),
            ),
            minimumSize: Size(width ?? 0, height ?? 0),
          ),
          child: buttonChild,
        );

      default:
        return ElevatedButton(
          onPressed: isButtonDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getBackgroundColor(),
            foregroundColor: _getForegroundColor(),
            padding: _paddingMap[size],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusMD),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
            minimumSize: Size(width ?? 0, height ?? 0),
          ),
          child: buttonChild,
        );
    }
  }
}
