# Flutter wrapper classes — do not obfuscate/strip.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Gson / JSON reflection used transitively by some plugins.
-keepattributes Signature
-keepattributes *Annotation*

# Play Core split-install classes referenced by Flutter's deferred-components
# support, unused here (no dynamic feature modules) — safe to ignore.
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication
