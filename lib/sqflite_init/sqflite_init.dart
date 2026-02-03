// Platform-safe sqflite initialization.
//
// - On mobile (Android/iOS): do nothing (sqflite works out of the box).
// - On desktop (Windows/Linux/macOS): initialize sqflite_common_ffi.
// - On web: do nothing (sqflite is not supported).
//
// We use conditional imports to avoid importing dart:io on web builds.

import 'sqflite_init_stub.dart'
    if (dart.library.io) 'sqflite_init_io.dart';

/// Call once at app startup (before any openDatabase usage).
void initSqflite() => initSqfliteImpl();

