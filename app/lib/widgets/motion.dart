import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../core/i18n.dart';
import '../core/tokens.dart';

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
  late final AnimationController _a = AnimationController(vsync: this, duration: Motion.medium2, value: widget.enabled ? 0 : 1);
  late final Animation<double> _curve = CurvedAnimation(parent: _a, curve: Motion.emphasizedDecelerate);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.enabled && _a.isDismissed) {
      // Reduced motion: appear at once.
      if (Motion.reduced(context)) {
        _a.value = 1;
      } else {
        _a.forward();
      }
    }
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
      child = AnimatedSize(duration: Motion.of(context, Motion.short3), curve: Motion.standard, alignment: Alignment.topCenter, child: child);
    }
    return child;
  }
}

/// RofuChat's custom loading visual (not an M3 Expressive component): a soft scalloped shape
/// inside a tinted disc that breathes between a circle and a flower while it turns. Every
/// motion is eased (the turn follows the emphasized curve each cycle, the morph a sine), it
/// is announced to screen readers as a progress indicator, and it holds still when the
/// platform asks for reduced motion.
class LoadingBlob extends StatefulWidget {
  final double size;

  /// Spoken label; defaults to "Generating".
  final String? semanticsLabel;
  const LoadingBlob({super.key, this.size = 30, this.semanticsLabel});
  @override
  State<LoadingBlob> createState() => _LoadingBlobState();
}

class _LoadingBlobState extends State<LoadingBlob> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _a
        ..stop()
        ..value = 0.25; // a still, half-scalloped shape
    } else if (!_a.isAnimating) {
      _a.repeat();
    }
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: widget.semanticsLabel ?? t('正在生成', 'Generating'),
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: widget.size,
          child: DecoratedBox(
            decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
            child: CustomPaint(painter: _BlobPainter(_a, scheme.onPrimaryContainer)),
          ),
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
    // Two eased half-turns per cycle: the spin speeds up and settles instead of turning at a
    // constant (linear) rate.
    final half = (v * 2) % 1;
    final rot = ((v * 2).floor() + Motion.emphasized.transform(half)) * math.pi;
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

/// Expands and collapses its child with a size + fade animation. The child stays built
/// while collapsing and is dropped once fully closed.
class Collapsible extends StatefulWidget {
  final bool open;
  final Widget child;
  final Duration duration;
  const Collapsible({super.key, required this.open, required this.child, this.duration = Motion.medium2});
  @override
  State<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: widget.duration, value: widget.open ? 1 : 0)
    ..addStatusListener((_) => setState(() {}));
  late final Animation<double> _size = CurvedAnimation(parent: _a, curve: Motion.emphasizedDecelerate, reverseCurve: Motion.emphasizedAccelerate);
  late final Animation<double> _fade = CurvedAnimation(
    parent: _a,
    curve: const Interval(0.25, 1, curve: Motion.standardDecelerate),
    reverseCurve: const Interval(0, 0.6, curve: Motion.standardAccelerate),
  );

  @override
  void didUpdateWidget(Collapsible old) {
    super.didUpdateWidget(old);
    if (widget.open != old.open) {
      if (Motion.reduced(context)) {
        _a.value = widget.open ? 1 : 0;
      } else {
        widget.open ? _a.forward() : _a.reverse();
      }
    }
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_a.isDismissed && !widget.open) return const SizedBox(width: double.infinity);
    return ClipRect(
      child: SizeTransition(
        sizeFactor: _size,
        axisAlignment: -1,
        child: FadeTransition(opacity: _fade, child: widget.child),
      ),
    );
  }
}

/// A chevron that turns smoothly between its closed and open directions.
class TurnChevron extends StatelessWidget {
  final bool open;
  final bool sideways;
  final double size;
  final Color? color;
  const TurnChevron({super.key, required this.open, this.sideways = false, this.size = 18, this.color});
  @override
  Widget build(BuildContext context) => AnimatedRotation(
        turns: open ? (sideways ? 0.25 : 0.5) : 0,
        duration: Motion.of(context, Motion.short4),
        curve: Motion.standard,
        child: Icon(sideways ? Icons.chevron_right : Icons.expand_more, size: size, color: color),
      );
}


/// Wraps the bottom sliver of the reversed chat list. While the list sits at the very bottom
/// (offset 0) its growth pushes older content up, so the view follows the stream. Once the
/// user has scrolled up, any growth is answered with an equal scroll-offset correction in the
/// same layout pass, so the content on screen does not move (as in RikkaHub).
class KeepStillSliver extends SingleChildRenderObjectWidget {
  const KeepStillSliver({super.key, required Widget sliver}) : super(child: sliver);
  @override
  RenderObject createRenderObject(BuildContext context) => _RenderKeepStill();
}

class _RenderKeepStill extends RenderProxySliver {
  double? _extent;

  @override
  void performLayout() {
    super.performLayout();
    final g = geometry!;
    if (g.scrollOffsetCorrection != null) return;
    final prev = _extent;
    _extent = g.scrollExtent;
    final delta = g.scrollExtent - (prev ?? g.scrollExtent);
    if (delta.abs() > 0.01 && constraints.scrollOffset > 0.5) {
      geometry = SliverGeometry(scrollOffsetCorrection: delta);
    }
  }
}
