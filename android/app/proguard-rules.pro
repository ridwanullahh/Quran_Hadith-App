# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Hive
-keep class * extends hive.HiveObject { *; }
-keepclassmembers class * extends hive.HiveObject { *; }
-dontwarn hive.**

# Riverpod
-dontwarn riverpod.**

# JSON serialization
-keep class * { *; }
-dontwarn com.google.gson.**
-dontwarn okio.**
