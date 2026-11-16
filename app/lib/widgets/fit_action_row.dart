import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A single-line action bar that never wraps.
///
/// When the children do not fit, the whole row scales down (to [minScale] at most). If it
/// still does not fit, children with a non-zero [ActionSlot.drop] are hidden, drop 1
/// first, then 2, and so on, until it does. Hidden actions must also be reachable elsewhere (the
/// message "More" menu). Children without an [ActionSlot] are never hidden.
class FitActionRow extends MultiChildRenderObjectWidget {
  final bool alignEnd;
  final double minScale;
  const FitActionRow({super.key, required super.children, this.alignEnd = false, this.minScale = 0.8});

  @override
  RenderFitActionRow createRenderObject(BuildContext context) =>
      RenderFitActionRow(alignEnd: alignEnd, minScale: minScale, textDirection: Directionality.of(context));

  @override
  void updateRenderObject(BuildContext context, RenderFitActionRow renderObject) {
    renderObject
      ..alignEnd = alignEnd
      ..minScale = minScale
      ..textDirection = Directionality.of(context);
  }
}

/// Marks a [FitActionRow] child as foldable; [drop] 1 is hidden first, then 2, and so on.
class ActionSlot extends ParentDataWidget<FitActionRowParentData> {
  final int drop;
  const ActionSlot({super.key, required this.drop, required super.child});

  @override
  void applyParentData(RenderObject renderObject) {
    final data = renderObject.parentData! as FitActionRowParentData;
    if (data.drop != drop) {
      data.drop = drop;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => FitActionRow;
}

class FitActionRowParentData extends ContainerBoxParentData<RenderBox> {
  int drop = 0;
  bool hidden = false;
}

class RenderFitActionRow extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, FitActionRowParentData>, RenderBoxContainerDefaultsMixin<RenderBox, FitActionRowParentData> {
  RenderFitActionRow({required bool alignEnd, required double minScale, required TextDirection textDirection})
      : _alignEnd = alignEnd, // ignore: prefer_initializing_formals
        _minScale = minScale, // ignore: prefer_initializing_formals
        _textDirection = textDirection; // ignore: prefer_initializing_formals

  bool _alignEnd;
  set alignEnd(bool v) {
    if (v == _alignEnd) return;
    _alignEnd = v;
    markNeedsLayout();
  }

  double _minScale;
  set minScale(double v) {
    if (v == _minScale) return;
    _minScale = v;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection v) {
    if (v == _textDirection) return;
    _textDirection = v;
    markNeedsLayout();
  }

  double _scale = 1;
  double _offsetX = 0;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FitActionRowParentData) child.parentData = FitActionRowParentData();
  }

  List<RenderBox> get _children {
    final out = <RenderBox>[];
    var c = firstChild;
    while (c != null) {
      out.add(c);
      c = childAfter(c);
    }
    return out;
  }

  FitActionRowParentData _data(RenderBox c) => c.parentData! as FitActionRowParentData;

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _children.fold(0.0, (sum, c) => sum + c.getMaxIntrinsicWidth(height));

  @override
  double computeMinIntrinsicHeight(double width) =>
      _children.fold(0.0, (h, c) => math.max(h, c.getMinIntrinsicHeight(double.infinity)));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _children.fold(0.0, (h, c) => math.max(h, c.getMaxIntrinsicHeight(double.infinity)));

  @override
  Size computeDryLayout(BoxConstraints constraints) => _layout(constraints, dry: true);

  @override
  void performLayout() => size = _layout(constraints, dry: false);

  Size _layout(BoxConstraints constraints, {required bool dry}) {
    final kids = _children;
    final sizes = <RenderBox, Size>{};
    for (final c in kids) {
      final loose = BoxConstraints(maxHeight: constraints.maxHeight);
      if (dry) {
        sizes[c] = c.getDryLayout(loose);
      } else {
        c.layout(loose, parentUsesSize: true);
        sizes[c] = c.size;
      }
    }
    final hidden = <RenderBox>{};
    double width() => kids.where((c) => !hidden.contains(c)).fold(0.0, (s, c) => s + sizes[c]!.width);
    final avail = constraints.maxWidth;
    if (avail.isFinite) {
      // Fold the lowest drop values first, one at a time, until the row fits at minScale.
      final foldable = kids.where((c) => _data(c).drop > 0).toList()..sort((a, b) => _data(a).drop.compareTo(_data(b).drop));
      for (final c in foldable) {
        if (width() * _minScale <= avail) break;
        hidden.add(c);
      }
    }
    final total = width();
    final scale = avail.isFinite && total > avail ? math.max(avail / total, 0.0) : 1.0;
    final height = kids.where((c) => !hidden.contains(c)).fold(0.0, (h, c) => math.max(h, sizes[c]!.height));
    final out = constraints.constrain(Size(avail.isFinite ? avail : total, height * scale));
    if (dry) return out;

    _scale = scale;
    final scaledWidth = total * scale;
    final atEnd = _alignEnd != (_textDirection == TextDirection.rtl);
    _offsetX = atEnd ? math.max(out.width - scaledWidth, 0) : 0;
    // Children are positioned in unscaled row space; paint applies the scale.
    final ordered = _textDirection == TextDirection.rtl ? kids.reversed : kids;
    var x = 0.0;
    for (final c in ordered) {
      final d = _data(c);
      d.hidden = hidden.contains(c);
      if (d.hidden) {
        d.offset = Offset.zero;
        continue;
      }
      d.offset = Offset(x, (height - c.size.height) / 2);
      x += c.size.width;
    }
    return out;
  }

  Matrix4 get _transform => Matrix4.identity()
    ..translateByDouble(_offsetX, 0, 0, 1)
    ..scaleByDouble(_scale, _scale, 1, 1);

  @override
  void paint(PaintingContext context, Offset offset) {
    context.pushTransform(needsCompositing, offset, _transform, (ctx, o) {
      for (final c in _children) {
        final d = _data(c);
        if (!d.hidden) ctx.paintChild(c, o + d.offset);
      }
    });
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(_transform);
    final d = _data(child);
    transform.translateByDouble(d.offset.dx, d.offset.dy, 0, 1);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintTransform(
      transform: _transform,
      position: position,
      hitTest: (r, p) {
        for (final c in _children.reversed) {
          final d = _data(c);
          if (d.hidden) continue;
          final hit = r.addWithPaintOffset(offset: d.offset, position: p, hitTest: (r2, p2) => c.hitTest(r2, position: p2));
          if (hit) return true;
        }
        return false;
      },
    );
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    for (final c in _children) {
      if (!_data(c).hidden) visitor(c);
    }
  }
}
