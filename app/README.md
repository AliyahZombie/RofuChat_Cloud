# RofuChat app (Flutter)

Spec: `../docs/frontend-spec.md`. Talks to the backend only through the HTTP/SSE API.

- Local backend: `tool/build_native.sh linux|windows|android` builds `backend/crates/rofu-ffi` and places the library where the build bundles it. Without it the app can still connect to a remote server.
- Run: `flutter run -d linux` (or windows / android / chrome).
- Test: `flutter analyze && flutter test`.

Layout: `lib/core` (API client, SSE, FFI, storage, theme, i18n), `lib/models`, `lib/state` (Riverpod),
`lib/features/*` (connect, chat, sidebar, characters, providers, tools, memory, settings, admin), `lib/widgets`.
Model icons in `assets/model_icons` come from lobehub/lobe-icons (MIT).
