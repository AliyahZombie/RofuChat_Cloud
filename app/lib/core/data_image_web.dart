import 'package:flutter/painting.dart';

// Let the browser fetch/decode data URLs asynchronously, without Dart base64 work.
ImageProvider dataImageProvider(String url) => NetworkImage(url);
