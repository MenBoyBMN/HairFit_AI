// ============================================================================
// File: lib/core/widgets/antigravity_card.dart
// Mục đích: Thành phần Card tương tác không trọng lực (Antigravity Design) dành cho Web & Mobile.
// Kết cấu:
//  - Hỗ trợ hiệu ứng nổi (Weightlessness), nghiêng 3D theo chuột (Spatial Depth),
//    và kính mờ (Glassmorphism) theo chuẩn bảng màu AppColors.
// ============================================================================

import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Card tương tác theo phong cách Antigravity Design
class AntigravityCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool enableGlassmorphism;
  final bool enable3DTilt;
  final bool enableHoverLift;

  const AntigravityCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.enableGlassmorphism = false,
    this.enable3DTilt = true,
    this.enableHoverLift = true,
  });

  @override
  State<AntigravityCard> createState() => _AntigravityCardState();
}

class _AntigravityCardState extends State<AntigravityCard> {
  bool _isHovered = false;
  Offset _mouseAlignment = Offset.zero; // [-1..1, -1..1]

  void _onHover(PointerEvent details, BoxConstraints constraints) {
    if (!widget.enable3DTilt) return;
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    if (width <= 0 || height <= 0 || !width.isFinite || !height.isFinite) {
      return;
    }

    final dx = ((details.localPosition.dx / width) - 0.5) * 2;
    final dy = ((details.localPosition.dy / height) - 0.5) * 2;

    setState(() {
      _mouseAlignment = Offset(dx.clamp(-1.0, 1.0), dy.clamp(-1.0, 1.0));
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final effectiveRadius = widget.borderRadius ?? AppDimensions.borderRadiusLg;
    final effectiveBg =
        widget.backgroundColor ??
        (widget.enableGlassmorphism
            ? AppColors.surface.withValues(alpha: 0.78)
            : AppColors.surface);

    final effectiveBorderColor = _isHovered
        ? AppColors.accent.withValues(alpha: 0.45)
        : (widget.borderColor ?? AppColors.border.withValues(alpha: 0.7));

    return LayoutBuilder(
      builder: (context, constraints) {
        final Matrix4 transform =
            (!reduceMotion && _isHovered && widget.enableHoverLift)
            ? Matrix4.translationValues(0.0, -5.0, 0.0)
            : Matrix4.identity();
        if (!reduceMotion && _isHovered && widget.enable3DTilt) {
          transform.setEntry(3, 2, 0.001);
          transform.rotateX(-_mouseAlignment.dy * 0.04);
          transform.rotateY(_mouseAlignment.dx * 0.04);
        }

        Widget cardContent = AnimatedContainer(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: widget.margin,
          transform: transform,
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: effectiveRadius,
            border: Border.all(
              color: effectiveBorderColor,
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.primary.withValues(alpha: 0.05),
                blurRadius: _isHovered ? 28 : 16,
                offset: Offset(0, _isHovered ? 14 : 6),
              ),
              if (_isHovered)
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: effectiveRadius,
            child: widget.enableGlassmorphism
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: _buildInner(effectiveRadius),
                  )
                : _buildInner(effectiveRadius),
          ),
        );

        return MouseRegion(
          cursor: widget.onTap != null
              ? SystemMouseCursors.click
              : MouseCursor.defer,
          onEnter: (_) => setState(() => _isHovered = true),
          onHover: (e) => _onHover(e, constraints),
          onExit: (_) => setState(() {
            _isHovered = false;
            _mouseAlignment = Offset.zero;
          }),
          child: cardContent,
        );
      },
    );
  }

  Widget _buildInner(BorderRadius effectiveRadius) {
    final content = widget.padding != null
        ? Padding(padding: widget.padding!, child: widget.child)
        : widget.child;

    if (widget.onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: effectiveRadius,
        onTap: widget.onTap,
        child: content,
      ),
    );
  }
}

// CreBy: MenBoyBMN
