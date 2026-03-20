## Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## For local_auth (Biometrics)
-keep class androidx.biometric.** { *; }
-dontwarn androidx.biometric.**

## For package_info_plus
-keep class io.flutter.plugins.packageinfo.** { *; }

## General Android support
-dontwarn io.flutter.**

# If using any custom model classes that are mapped via reflection, add keep rules for them here.
