import 'package:flutter/material.dart';

/// A left drawer that follows the finger while dragged and settles with an eased
/// (non-linear) animation, replacing Scaffold's linear drawer. A horizontal drag anywhere
/// opens it; tapping the scrim, dragging left or Back closes it.
class SlideDrawer extends StatefulWidget {
  final Widget child;
  final Widget drawer;
  final double width;
  const SlideDrawer({super.key, required this.child, required this.drawer, required this.width});

  /// The enclosing drawer, if any (the sidebar uses it to close itself).
  static SlideDrawerState? maybeOf(BuildContext context) => context.findAncestorStateOfType<SlideDrawerState>();

  @override
  State<SlideDrawer> createState() => SlideDrawerState();
}

class SlideDrawerState extends State<SlideDrawer> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this)..addListener(() => setState(() {}));
  bool _dragging = false;

  bool get isOpen => _a.value > 0;

  void open() => _a.animateTo(1, duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
  void close() => _a.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);

  void _settle(double velocity) {
    _dragging = false;
    final open = velocity.abs() > 365 ? velocity > 0 : _a.value > 0.5;
    // Keep the throw's momentum feel: a faster fling settles a bit quicker.
    final speed = (velocity.abs() / 2000).clamp(0.0, 1.0);
    final ms = (open ? 380 : 300) * (1 - 0.4 * speed);
    _a.animateTo(
      open ? 1 : 0,
      duration: Duration(milliseconds: ms.round()),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = _a.value;
    final w = widget.width;
    return PopScope(
      canPop: v == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) close();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) {
          _a.stop();
          _dragging = true;
        },
        onHorizontalDragUpdate: (d) => _a.value = (_a.value + d.primaryDelta! / w).clamp(0.0, 1.0),
        onHorizontalDragEnd: (d) => _settle(d.primaryVelocity ?? 0),
        onHorizontalDragCancel: () => _settle(0),
        child: Stack(
          children: [
            widget.child,
            if (v > 0 || _dragging) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: close,
                  child: ColoredBox(color: Colors.black.withValues(alpha: 0.4 * v)),
                ),
              ),
              Positioned(
                left: -w * (1 - v),
                top: 0,
                bottom: 0,
                width: w,
                child: RepaintBoundary(
                  child: Drawer(width: w, child: widget.drawer),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
