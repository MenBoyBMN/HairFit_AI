// ============================================================================
// File: lib/core/widgets/staggered_reveal.dart
// Mục đích: Hiệu ứng chuyển động xuất hiện tuần tự (Staggered Entrance) chuẩn Antigravity Design.
// Kết cấu:
//  - Sử dụng AnimationController kết hợp Interval để không tạo Timer treo trong Widget Tests.
//  - Tôn trọng cấu hình prefers-reduced-motion của người dùng.
// ============================================================================

import 'package:flutter/material.dart';

/// Widget tạo hiệu ứng trượt nhẹ từ trục Y kèm mờ dần theo thứ tự index
class StaggeredReveal extends StatefulWidget {
  final int index;
  final Widget child;
  final double offsetY;
  final Duration baseDuration;

  const StaggeredReveal({
    super.key,
    required this.index,
    required this.child,
    this.offsetY = 18.0,
    this.baseDuration = const Duration(milliseconds: 450),
  });

  @override
  State<StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<StaggeredReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.baseDuration,
    );

    final startInterval = (widget.index * 0.1).clamp(0.0, 0.6);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(startInterval, 1.0, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1.0 - value) * widget.offsetY),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// CreBy: MenBoyBMN
