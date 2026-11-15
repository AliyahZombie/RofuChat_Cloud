import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

final _decoded = <String, Future<Uint8List>>{};
int _encodedChars = 0;

Future<Uint8List> _bytes(String url) {
  final found = _decoded.remove(url);
  if (found != null) {
    _decoded[url] = found;
    return found;
  }
  // Bound retained legacy input/bytes to roughly 16MB, retaining one large image.
  while (_decoded.isNotEmpty && _encodedChars + url.length > 16 * 1024 * 1024) {
    final oldest = _decoded.keys.first;
    _encodedChars -= oldest.length;
    _decoded.remove(oldest);
  }
  _encodedChars += url.length;
  return _decoded[url] = compute(_decode, url);
}

Uint8List _decode(String url) =>
    base64Decode(url.substring(url.indexOf(',') + 1));

ImageProvider dataImageProvider(String url) => _DataImage(url);

/// ImageCache uses the URL's cached hash/equality, so rebuilds share one isolate decode.
@immutable
class _DataImage extends ImageProvider<_DataImage> {
  final String url;
  const _DataImage(this.url);
  @override
  Future<_DataImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);
  @override
  ImageStreamCompleter loadImage(_DataImage key, ImageDecoderCallback decode) =>
      MultiFrameImageStreamCompleter(codec: _load(decode), scale: 1);
  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final bytes = await _bytes(url);
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) => other is _DataImage && other.url == url;
  @override
  int get hashCode => url.hashCode;
}
