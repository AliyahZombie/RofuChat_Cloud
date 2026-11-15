import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/i18n.dart';
import '../core/image_providers.dart';
import '../core/tokens.dart';
import '../state/app_state.dart';

/// A stable image slot. Offscreen children of the eagerly built KeepStillSliver tail
/// remain placeholders until they approach the viewport; merely building never fetches.
class AsyncImage extends ConsumerStatefulWidget {
  final Object source;
  final double width;
  final double? height;
  final BoxFit fit;
  const AsyncImage({
    super.key,
    required this.source,
    this.width = 96,
    this.height,
    this.fit = BoxFit.cover,
  });
  @override
  ConsumerState<AsyncImage> createState() => _AsyncImageState();
}

class _AsyncImageState extends ConsumerState<AsyncImage> {
  ScrollPosition? _position;
  bool _near = false;
  bool _checkPending = false;
  int _retry = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _position?.removeListener(_scheduleCheck);
    _position = Scrollable.maybeOf(context)?.position;
    _position?.addListener(_scheduleCheck);
    _scheduleCheck();
  }

  void _scheduleCheck() {
    if (_near || _checkPending) return;
    _checkPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPending = false;
      if (!mounted || _near) return;
      final box = context.findRenderObject();
      if (box is! RenderBox || !box.hasSize) return;
      final viewport = RenderAbstractViewport.maybeOf(box) as RenderObject?;
      final bounds = viewport != null
          ? MatrixUtils.transformRect(
              viewport.getTransformTo(null),
              viewport.paintBounds,
            )
          : Offset.zero & MediaQuery.sizeOf(context);
      final rect = MatrixUtils.transformRect(
        box.getTransformTo(null),
        box.paintBounds,
      );
      // Performance prefetch distance, independent of visual spacing tokens.
      if (bounds.inflate(200).overlaps(rect)) setState(() => _near = true);
    });
  }

  @override
  void didUpdateWidget(covariant AsyncImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) _retry = 0;
  }

  @override
  void dispose() {
    _position?.removeListener(_scheduleCheck);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleCheck();
    final source = widget.source;
    final metadata = source is Map ? source : const {};
    final w = (metadata['width'] as num?)?.toDouble() ?? 0;
    final h = (metadata['height'] as num?)?.toDouble() ?? 0;
    final height =
        widget.height ?? (w > 0 && h > 0 ? widget.width * h / w : widget.width);
    final scheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      key: const ValueKey('image-placeholder'),
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.image_outlined, color: scheme.onSurfaceVariant),
      ),
    );
    Widget child = placeholder;
    if (_near) {
      final path = source is String
          ? source
          : '/api/attachments/${metadata['id']}';
      final url = ref.watch(apiProvider).authedUrl(path);
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final provider = cachedImageProvider(
        url,
        width: (widget.width * dpr).ceil().clamp(1, 4096),
        height: (height * dpr).ceil().clamp(1, 4096),
      );
      child = Image(
        key: ValueKey((url, _retry)),
        image: provider,
        fit: widget.fit,
        frameBuilder: (c, image, frame, synchronous) => Stack(
          fit: StackFit.expand,
          children: [
            placeholder,
            AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: Motion.of(c, Motion.medium2),
              curve: Motion.emphasizedDecelerate,
              child: image,
            ),
          ],
        ),
        errorBuilder: (c, error, stack) => ColoredBox(
          color: scheme.errorContainer,
          child: Center(
            child: IconButton(
              tooltip: t('图片加载失败，重试', 'Image failed to load. Retry'),
              color: scheme.onErrorContainer,
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () async {
                await provider.evict();
                if (mounted) setState(() => _retry++);
              },
            ),
          ),
        ),
      );
    }
    return SizedBox(width: widget.width, height: height, child: child);
  }
}
