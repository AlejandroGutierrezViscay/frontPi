import 'package:flutter/material.dart';
import '../config/theme.dart';

enum CustomButtonType { primary, secondary, outline, text, google }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = CustomButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget button = _buildButton(context);

    if (widget.isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    } else if (widget.width != null) {
      button = SizedBox(width: widget.width, child: button);
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: button);
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    switch (widget.type) {
      case CustomButtonType.primary:
        return _buildPrimaryButton(context);
      case CustomButtonType.secondary:
        return _buildSecondaryButton(context);
      case CustomButtonType.outline:
        return _buildOutlineButton(context);
      case CustomButtonType.text:
        return _buildTextButton(context);
      case CustomButtonType.google:
        return _buildGoogleButton(context);
    }
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return Container(
      height: widget.height ?? 56,
      decoration: BoxDecoration(
        gradient: widget.onPressed != null && !widget.isLoading
            ? AppColors.primaryGradient
            : null,
        color: widget.onPressed == null || widget.isLoading
            ? AppColors.textDisabled
            : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: widget.onPressed != null && !widget.isLoading
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: _buildButtonContent(Colors.white),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return Container(
      height: widget.height ?? 56,
      decoration: BoxDecoration(
        gradient: widget.onPressed != null && !widget.isLoading
            ? AppColors.primaryGradient
            : null,
        color: widget.onPressed == null || widget.isLoading
            ? AppColors.textDisabled
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: _buildButtonContent(Colors.white),
      ),
    );
  }

  Widget _buildOutlineButton(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 56,
      child: OutlinedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: widget.onPressed != null && !widget.isLoading
                ? AppColors.primary
                : AppColors.textDisabled,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: _buildButtonContent(AppColors.primary),
      ),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 48,
      child: TextButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: _buildButtonContent(AppColors.primary),
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return Container(
      height: widget.height ?? 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/google_logo.png',
              height: 20,
              width: 20,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.g_mobiledata,
                  size: 24,
                  color: AppColors.primary,
                );
              },
            ),
            const SizedBox(width: 12),
            _buildButtonContent(AppColors.textPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (widget.isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.icon!,
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
