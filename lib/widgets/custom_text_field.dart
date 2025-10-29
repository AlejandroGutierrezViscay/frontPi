import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final bool showCounter;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.contentPadding,
    this.showCounter = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  late FocusNode _focusNode;
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    // Verificar si ya hay texto inicial
    _hasText = widget.controller?.text.isNotEmpty ?? false;
    if (_hasText) {
      _animationController.value = 1.0;
    }

    // Escuchar cambios en el controller
    widget.controller?.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    widget.controller?.removeListener(_onTextChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });

    if (_hasFocus || _hasText) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onTextChange() {
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });

      if (_hasText || _hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : hasError
                ? [
                    BoxShadow(
                      color: AppColors.error.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                obscureText: widget.obscureText,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                maxLength: widget.showCounter ? widget.maxLength : null,
                onTap: widget.onTap,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                validator: widget.validator,
                inputFormatters: widget.inputFormatters,
                style: TextStyle(
                  color: widget.enabled
                      ? AppColors.textPrimary
                      : AppColors.textDisabled,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  // Solo mostrar hintText si no hay label o si el label no está flotando
                  hintText: (widget.label == null || (!_hasFocus && !_hasText))
                      ? widget.hintText
                      : null,
                  hintStyle: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 16,
                  ),
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  contentPadding:
                      widget.contentPadding ??
                      EdgeInsets.fromLTRB(
                        16,
                        widget.label != null
                            ? 24
                            : 20, // Más espacio arriba si hay label
                        16,
                        12,
                      ),
                  filled: true,
                  fillColor: widget.enabled
                      ? AppColors.surface
                      : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                  counterText: widget.showCounter ? null : '',
                ),
              ),

              // Label flotante animado
              if (widget.label != null)
                Positioned(
                  left: 12,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final progress = _animation.value;
                      final isFloating = progress > 0.5;

                      return Transform.translate(
                        offset: Offset(
                          4 * (1 - progress),
                          isFloating ? -10 : 18, // Mejorar posicionamiento
                        ),
                        child: Transform.scale(
                          scale: isFloating ? 0.75 : 1.0,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: isFloating
                                ? const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ) // Más padding
                                : EdgeInsets.zero,
                            decoration: isFloating
                                ? BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(4),
                                  )
                                : null,
                            child: Text(
                              widget.label!,
                              style: TextStyle(
                                color: hasError
                                    ? AppColors.error
                                    : _hasFocus
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontSize: isFloating ? 12 : 16,
                                fontWeight: isFloating
                                    ? FontWeight
                                          .w600 // Más bold cuando flota
                                    : FontWeight.normal,
                                height: 1.2, // Controlar altura de línea
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),

        // Texto de ayuda o error
        if (widget.helperText != null || widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(
              widget.errorText ?? widget.helperText!,
              style: TextStyle(
                color: hasError ? AppColors.error : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

// Widget especializado para contraseñas
class PasswordTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;

  const PasswordTextField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.focusNode,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: widget.label,
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      controller: widget.controller,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      validator: widget.validator,
      focusNode: widget.focusNode,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}
