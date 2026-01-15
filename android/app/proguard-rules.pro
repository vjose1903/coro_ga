# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Billing
-keep class com.android.vending.billing.**

# Keep Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}


