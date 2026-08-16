# ─────────────────────────────────────────────────────────────────────
# MinhaajulHudaa — ProGuard / R8 rules
# ─────────────────────────────────────────────────────────────────────
# Goal: enable minification + obfuscation on release builds while keeping
# the runtime-reflected classes (Hive boxes, Riverpod providers, model
# fromJson methods) intact. The previous blanket `-keep class * { *; }`
# defeated minification entirely — it has been removed.

# ── Flutter wrapper ─────────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# ── Hive (runtime type adapter registration) ────────────────────────
# Hive uses reflection to read/write fields. Keep all HiveObject
# subclasses and their fields. Also keep TypeAdapter implementations.
-keep class * extends com.hivedb.HiveObject { *; }
-keepclassmembers class * extends com.hivedb.HiveObject { *; }
-keep class * implements com.hivedb.TypeAdapter { *; }
-keepclassmembers class * implements com.hivedb.TypeAdapter {
    public <init>(...);
}
-keep @com.hivedb.HiveType class *
-keepclassmembers @com.hivedb.HiveType class * {
    *;
}
-dontwarn com.hivedb.**

# ── Riverpod ────────────────────────────────────────────────────────
# Riverpod uses runtime types but not aggressive reflection. Just suppress
# warnings; no explicit keep rules needed.
-dontwarn riverpod.**

# ── Model classes (fromJson / toJson reflection) ───────────────────
# Keep all classes in the data/models package and their (de)serializers.
-keep class com.minhaajulhudaa.quran.data.models.** { *; }
-keepclassmembers class com.minhaajulhudaa.quran.data.models.** {
    public <init>(...);
    public *** get*();
    public void set*(...);
}

# ── just_audio + audio_session ──────────────────────────────────────
-keep class com.ryanheise.just_audio.** { *; }
-dontwarn com.ryanheise.just_audio.**

# ── sqflite ─────────────────────────────────────────────────────────
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# ── flutter_local_notifications ─────────────────────────────────────
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# ── Coroutines (used by just_audio + flutter_local_notifications) ───
-keepclassmembers class kotlinx.coroutines.** {
    volatile <fields>;
}
-dontwarn kotlinx.coroutines.**

# ── Gson (transitive via some plugins) ──────────────────────────────
-dontwarn com.google.gson.**
-keepattributes Signature
-keepattributes *Annotation*

# ── OkHttp / Okio (transitive via dio + just_audio) ─────────────────
-dontwarn okhttp3.**
-dontwarn okio.**

# ── General defensive keeps ─────────────────────────────────────────
# Keep enum values (used by switch statements in deserialization)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep generic signatures for type-safe deserialization
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ── Missing class suppressions ──────────────────────────────────────
# Flutter references Play Core classes for deferred components and
# SplitCompatApplication, but this app does not use Play Feature Delivery,
# so the classes are absent from the classpath. R8 full mode (AGP 8+)
# treats missing class references as build errors even with -dontwarn in
# some cases. Suppress broadly for the entire Play Core package.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Specifically referenced classes (for R8 full mode missing-class report):
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.review.**
-dontwarn com.google.android.play.core.assetpacks.**
-dontwarn com.google.android.play.core.common.**
-dontwarn com.google.android.play.core.tasks.**
