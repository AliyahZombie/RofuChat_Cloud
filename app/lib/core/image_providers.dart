import 'package:flutter/painting.dart';

import 'data_image_native.dart'
    if (dart.library.js_interop) 'data_image_web.dart';

/// Bounded provider memoization plus Flutter's byte-limited decoded ImageCache. The URL
/// includes server and auth token, keeping users and embedded/remote servers isolated.
final _providers = <(String, int, int), ImageProvider>{};
ImageProvider cachedImageProvider(
  String url, {
  required int width,
  required int height,
}) {
  final key = (url, width, height);
  final found = _providers.remove(key);
  if (found != null) {
    _providers[key] = found;
    return found;
  }
  final base = url.startsWith('data:')
      ? dataImageProvider(url)
      : NetworkImage(url);
  final provider = ResizeImage(
    base,
    width: width,
    height: height,
    policy: ResizeImagePolicy.fit,
  );
  _providers[key] = provider;
  if (_providers.length > 64) _providers.remove(_providers.keys.first);
  return provider;
}
