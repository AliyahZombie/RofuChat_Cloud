import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rofuchat/core/api.dart';
import 'package:rofuchat/core/image_providers.dart';
import 'package:rofuchat/core/tokens.dart';
import 'package:rofuchat/models/models.dart';
import 'package:rofuchat/features/chat/message_rows.dart';
import 'package:rofuchat/widgets/motion.dart';
import 'package:rofuchat/state/app_state.dart';
import 'package:rofuchat/widgets/async_image.dart';
import 'package:rofuchat/widgets/common.dart';

Widget host(Widget child) => ProviderScope(
  overrides: [
    apiProvider.overrideWithValue(Api('http://127.0.0.1:9999', token: 'test')),
  ],
  child: MaterialApp(home: Scaffold(body: child)),
);

void main() {
  testWidgets('reference reserves aspect ratio before any image fetch', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        const Align(
          alignment: Alignment.topLeft,
          child: AsyncImage(
            source: {
              'id': 'image',
              'mime': 'image/png',
              'width': 200,
              'height': 100,
              'bytes': 1000,
            },
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('image-placeholder')), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(t.getSize(find.byType(AsyncImage)), const Size(96, 48));
    await t.pumpWidget(const SizedBox());
  });

  for (final reverse in [false, true]) {
    testWidgets(
      'eager sliver tail loads only near the viewport (reverse=$reverse); failure can retry',
      (t) async {
        final scroll = ScrollController();
        await t.pumpWidget(
          host(
            CustomScrollView(
              controller: scroll,
              reverse: reverse,
              slivers: [
                KeepStillSliver(
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        if (!reverse) const SizedBox(height: 2000),
                        const AsyncImage(
                          source: {
                            'id': 'image',
                            'mime': 'image/png',
                            'bytes': 1000,
                          },
                        ),
                        if (reverse) const SizedBox(height: 2000),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        await t.pump();
        expect(find.byType(AsyncImage), findsOneWidget);
        expect(find.byType(Image), findsNothing);
        scroll.jumpTo(scroll.position.maxScrollExtent);
        await t.pump();
        await t.pump();
        expect(find.byType(Image), findsOneWidget);
        final sized = t.widget<Image>(find.byType(Image)).image as ResizeImage;
        expect(
          (sized.imageProvider as NetworkImage).url,
          'http://127.0.0.1:9999/api/attachments/image?token=test',
        );
        expect(sized.width, (96 * t.view.devicePixelRatio).ceil());
        await t.pumpAndSettle();
        expect(find.byTooltip('Image failed to load. Retry'), findsOneWidget);
        await t.tap(find.byTooltip('Image failed to load. Retry'));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        scroll.dispose();
      },
    );
  }

  testWidgets(
    'legacy data image loads asynchronously and fades without changing its slot',
    (t) async {
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetDevicePixelRatio);
      const source =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==';
      // Resolve the real native provider (including its isolate) outside the fake clock.
      await t.runAsync(() async {
        final ready = Completer<void>();
        final stream = cachedImageProvider(
          source,
          width: 96,
          height: 96,
        ).resolve(ImageConfiguration.empty);
        final listener = ImageStreamListener(
          (_, _) => ready.complete(),
          onError: (Object e, StackTrace? s) => ready.completeError(e, s),
        );
        stream.addListener(listener);
        try {
          await ready.future.timeout(const Duration(seconds: 10));
        } finally {
          stream.removeListener(listener);
        }
      });
      await t.pumpWidget(
        host(
          const Align(
            alignment: Alignment.topLeft,
            child: AsyncImage(source: source),
          ),
        ),
      );
      final size = t.getSize(find.byType(AsyncImage));
      await t.pump();
      await t.pump();
      final fade = t.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(fade.opacity, 1);
      expect(fade.curve, Motion.emphasizedDecelerate);
      await t.pumpAndSettle();
      expect(t.getSize(find.byType(AsyncImage)), size);
      expect(find.byTooltip('Image failed to load. Retry'), findsNothing);
    },
  );

  testWidgets(
    'message text precedes its reference image and full-size preview stays bounded',
    (t) async {
      t.view.physicalSize = const Size(360, 800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        host(
          ListView(
            children: [
              UserBubble(
                msg: Message({
                  'id': 'm',
                  'role': 'user',
                  'content': 'Text first',
                  'parts': {
                    'images': [
                      {
                        'id': 'preview',
                        'mime': 'image/png',
                        'width': 200,
                        'height': 100,
                        'bytes': 1000,
                      },
                    ],
                  },
                }),
                userName: 'User',
                showName: false,
                onCopy: () {},
                onEdit: () {},
                onMore: (_) {},
              ),
            ],
          ),
        ),
      );
      expect(find.text('Text first'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(t.getSize(find.byType(AsyncImage)), const Size(96, 48));
      await t.tap(find.byType(AsyncImage));
      await t.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      final size = t.getSize(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byType(AsyncImage),
        ),
      );
      expect(size.width, lessThanOrEqualTo(360));
      expect(size.height, lessThanOrEqualTo(800));
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('avatar image provider is identical across rebuilds', (t) async {
    final c = Character({
      'id': 'c',
      'name': 'Alice',
      'avatar': '/api/attachments/avatar',
    });
    await t.pumpWidget(host(CharacterAvatar(character: c)));
    final first = t.widget<Image>(find.byType(Image)).image;
    await t.pumpWidget(host(CharacterAvatar(character: c)));
    expect(identical(t.widget<Image>(find.byType(Image)).image, first), isTrue);
    await t.pumpAndSettle();
  });

  test('legacy providers share a hash key and message/composer builds do no base64 decoding', () {
    const data = 'data:image/png;base64,eA==';
    expect(
      identical(
        cachedImageProvider(data, width: 96, height: 96),
        cachedImageProvider(data, width: 96, height: 96),
      ),
      isTrue,
    );
    for (final path in [
      'lib/features/chat/message_rows.dart',
      'lib/features/chat/chat_page.dart',
      'lib/widgets/common.dart',
    ]) {
      expect(
        File(path).readAsStringSync().contains('base64Decode'),
        isFalse,
        reason: path,
      );
    }
    expect(
      File('lib/core/data_image_native.dart').readAsStringSync(),
      contains('compute(_decode, url)'),
    );
  });
}
