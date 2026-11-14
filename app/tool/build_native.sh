#!/usr/bin/env bash
# Build the embedded backend (backend/crates/rofu-ffi) and place it where the Flutter build picks it up.
# Usage: tool/build_native.sh linux|windows|android
set -euo pipefail
cd "$(dirname "$0")/.."
APP=$(pwd); BACKEND="$APP/../backend"
target_dir=${CARGO_TARGET_DIR:-$BACKEND/target}
case "${1:-}" in
  linux)
    (cd "$BACKEND" && cargo build -p rofu-ffi --release)
    mkdir -p native/linux && cp "$target_dir/release/librofu_ffi.so" native/linux/ ;;
  windows)
    (cd "$BACKEND" && cargo build -p rofu-ffi --release)
    mkdir -p native/windows && cp "$target_dir/release/rofu_ffi.dll" native/windows/ ;;
  android)
    # requires: cargo install cargo-ndk; rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android
    (cd "$BACKEND" && cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 -o "$APP/android/app/src/main/jniLibs" build -p rofu-ffi --release) ;;
  *) echo "usage: $0 linux|windows|android"; exit 1 ;;
esac
