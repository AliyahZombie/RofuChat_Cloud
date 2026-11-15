import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/i18n.dart';

/// Guards the root page against accidental exits on Back.
///
/// Back first hides the keyboard (drops text focus), then lets [isBusy] handlers such as an
/// open drawer consume it, and only then asks for a second Back within [window] to exit.
class BackGuard extends StatefulWidget {
  final Widget child;

  /// True while something else on the page (an open drawer) will handle this Back itself.
  final bool Function()? isBusy;
  final Duration window;

  /// Called on the confirmed exit. Defaults to [SystemNavigator.pop].
  final VoidCallback? onExit;
  const BackGuard({
    super.key,
    required this.child,
    this.isBusy,
    this.window = const Duration(seconds: 2),
    this.onExit,
  });

  @override
  State<BackGuard> createState() => _BackGuardState();
}

class _BackGuardState extends State<BackGuard> {
  DateTime? _last;

  void _onBack() {
    if (widget.isBusy?.call() ?? false) {
      _last = null;
      return;
    }
    final focus = FocusManager.instance.primaryFocus;
    final editing =
        focus != null &&
        focus.context?.findAncestorWidgetOfExactType<EditableText>() != null;
    if (editing || MediaQuery.viewInsetsOf(context).bottom > 0) {
      focus?.unfocus();
      SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
      _last = null;
      return;
    }
    final now = DateTime.now();
    if (_last != null && now.difference(_last!) <= widget.window) {
      (widget.onExit ?? SystemNavigator.pop)();
      return;
    }
    _last = now;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(t('再按一次返回键退出', 'Press Back again to exit')),
          duration: widget.window,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: widget.child,
    );
  }
}
