# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.platform.** { *; }

# Keep your application classes that will be accessed through reflection
-keep class com.example.flutter_1.** { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep Kotlin Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# Keep JustAudio plugin
-keep class com.ryanheise.just_audio.** { *; }

# Keep FileProvider
-keep class androidx.core.content.FileProvider
-keep class androidx.core.content.FileProvider$PathStrategy

# Keep Permissions Handler
-keep class com.baseflow.permissionhandler.** { *; }

# General Android
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions 