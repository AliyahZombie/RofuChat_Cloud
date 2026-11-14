import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fades and slides its child in the first time it is built, and smoothly animates later
/// size changes (a paragraph growing while it streams). With [enabled] false it is inert,
/// so finished messages never re-animate when scrolled back into view.
class Appear extends StatefulWidget {
  final Widget child;
  final bool enabled;
  const Appear({super.key, required this.child, this.enabled = true});
  @override
  State<Appear> createState() => _AppearState();
}

class _AppearState extends State<Appear> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: const Duration(milliseconds: 320), value: widget.enabled ? 0 : 1);
  late final Animation<double> _curve = CurvedAnimation(parent: _a, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _a.forward();
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (_, c) {
        final v = _curve.value;
        if (v >= 1) return c!;
        return Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 10 * (1 - v)), child: c));
      },
    );
    if (widget.enabled) {
      child = AnimatedSize(duration: const Duration(milliseconds: 160), curve: Curves.easeOut, alignment: Alignment.topCenter, child: child);
    }
    return child;
  }
}

/// A Material 3 expressive style loading indicator: a soft scalloped shape inside a tinted
/// disc that breathes between a circle and a flower while it spins.
class LoadingBlob extends StatefulWidget {
  final double size;
  const LoadingBlob({super.key, this.size = 30});
  @override
  State<LoadingBlob> createState() => _LoadingBlobState();
}

class _LoadingBlobState extends State<LoadingBlob> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: DecoratedBox(
          decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
          child: CustomPaint(painter: _BlobPainter(_a, scheme.onPrimaryContainer)),
        ),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final Animation<double> t;
  final Color color;
  _BlobPainter(this.t, this.color) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    final v = t.value;
    final c = size.center(Offset.zero);
    final base = size.shortestSide * 0.3;
    // lobes morph 0 → 7 bumps and back; scale pulses; whole shape spins
    final morph = (math.sin(v * 2 * math.pi * 2) + 1) / 2;
    final lobes = 7;
    final amp = base * 0.22 * morph;
    final scale = 0.9 + 0.1 * math.sin(v * 2 * math.pi * 2 + math.pi / 2);
    final rot = v * 2 * math.pi;
    final path = Path();
    const steps = 96;
    for (var i = 0; i <= steps; i++) {
      final a = i / steps * 2 * math.pi;
      final r = (base + amp * math.cos(lobes * a)) * scale;
      final p = c + Offset(math.cos(a + rot), math.sin(a + rot)) * r;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter o) => o.color != color;
}
