import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/tokens.dart';

/// A left modal drawer that follows the finger while dragged (direct manipulation) and
/// settles with an eased, non-linear animation, replacing Scaffold's linear drawer. A
/// rightward drag starting in the left [openZone] of the screen opens it; tapping the scrim,
/// dragging left, Escape or Back closes it.
///
/// While open it behaves as a modal: the page below is removed from focus traversal and the
/// semantics tree, focus moves into the drawer and is restored on close, and the scrim is a
/// labelled dismiss barrier.
class SlideDrawer extends StatefulWidget {
  final Widget child;
  final Widget drawer;
  final double width;

  /// Fraction of the screen width, from the left edge, where a drag may open the drawer.
  final double openZone;

  /// Whether the drawer closes itself on Back. Set false when an enclosing [BackGuard]
  /// coordinates Back (keyboard first, then the drawer, then double Back to exit).
  final bool handleBack;
  const SlideDrawer({
    super.key,
    required this.child,
    required this.drawer,
    required this.width,
    this.openZone = 0.6,
    this.handleBack = true,
  });

  /// The enclosing drawer, if any (the sidebar uses it to close itself).
  static SlideDrawerState? maybeOf(BuildContext context) => context.findAncestorStateOfType<SlideDrawerState>();

  @override
  State<SlideDrawer> createState() => SlideDrawerState();
}

class SlideDrawerState extends State<SlideDrawer> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this)
    ..addListener(() => setState(() {}))
    ..addStatusListener(_onStatus);
  final _drawerScope = FocusScopeNode(debugLabel: 'SlideDrawer');
  FocusNode? _restore;
  bool _dragging = false;
  bool _ignore = false;

  bool get isOpen => _a.value > 0;

  void _onStatus(AnimationStatus s) {
    if (s == AnimationStatus.dismissed) {
      final r = _restore;
      _restore = null;
      if (r != null && r.context != null && r.canRequestFocus) r.requestFocus();
    }
  }

  void _grabFocus() {
    if (_restore == null && _a.value == 0) {
      final f = FocusManager.instance.primaryFocus;
      // Remember the page's focus (not the keyboard field: reopening the IME is not wanted).
      if (f != null && f.context?.findAncestorWidgetOfExactType<EditableText>() == null) _restore = f;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && isOpen && (ModalRoute.of(context)?.isCurrent ?? true)) _drawerScope.requestFocus();
    });
  }

  Duration _dur(Duration d) => Motion.of(context, d);

  void open() {
    _grabFocus();
    _a.animateTo(1, duration: _dur(Motion.medium4), curve: Motion.emphasizedDecelerate);
  }

  void close() => _a.animateTo(0, duration: _dur(Motion.medium2), curve: Motion.emphasizedAccelerate);

  void _settle(double velocity) {
    _dragging = false;
    final open = velocity.abs() > 365 ? velocity > 0 : _a.value > 0.5;
    // Keep the throw's momentum feel: a faster fling settles a bit quicker. The settle is
    // eased; only the drag itself follows the finger directly.
    final speed = (velocity.abs() / 2000).clamp(0.0, 1.0);
    final base = open ? Motion.medium4 : Motion.medium2;
    final ms = base.inMilliseconds * (1 - 0.4 * speed);
    if (open) _grabFocus();
    _a.animateTo(
      open ? 1 : 0,
      duration: _dur(Duration(milliseconds: ms.round())),
      curve: open ? Motion.emphasizedDecelerate : Motion.emphasizedAccelerate,
    );
  }

  @override
  void dispose() {
    _a.dispose();
    _drawerScope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = _a.value;
    final w = widget.width;
    final scheme = Theme.of(context).colorScheme;
    final modal = v > 0 || _dragging;
    Widget body = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (d) {
        final screen = context.size?.width ?? MediaQuery.sizeOf(context).width;
        _ignore = _a.value == 0 && d.localPosition.dx > screen * widget.openZone;
        if (_ignore) return;
        _a.stop();
        _dragging = true;
      },
      onHorizontalDragUpdate: (d) {
        if (!_ignore) _a.value = (_a.value + d.primaryDelta! / w).clamp(0.0, 1.0);
      },
      onHorizontalDragEnd: (d) {
        if (!_ignore) _settle(d.primaryVelocity ?? 0);
      },
      onHorizontalDragCancel: () {
        // Cancellation also happens when a child long press wins before a drag
        // starts. Settling then would schedule drawer focus over its new sheet.
        if (!_ignore && _dragging) _settle(0);
      },
      child: Stack(
        children: [
          // The covered page leaves focus traversal and the semantics tree while the
          // drawer is shown, so keyboard and screen-reader users stay inside the modal.
          ExcludeFocus(
            excluding: modal,
            child: ExcludeSemantics(excluding: modal, child: widget.child),
          ),
          if (modal) ...[
            Positioned.fill(
              child: Opacity(
                opacity: v,
                child: ModalBarrier(
                  color: scheme.scrim.withValues(alpha: 0.32),
                  dismissible: true,
                  onDismiss: close,
                  semanticsLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                ),
              ),
            ),
            Positioned(
              left: -w * (1 - v),
              top: 0,
              bottom: 0,
              width: w,
              child: RepaintBoundary(
                child: CallbackShortcuts(
                  bindings: {const SingleActivator(LogicalKeyboardKey.escape): close},
                  child: FocusScope(
                    node: _drawerScope,
                    // Drawer supplies the route semantics and its localized label.
                    child: Drawer(width: w, child: widget.drawer),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
    if (!widget.handleBack) return body;
    return PopScope(
      canPop: v == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) close();
      },
      child: body,
    );
  }
}
