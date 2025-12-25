# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Dio HTTP client
-keep class dio.** { *; }
-dontwarn dio.**

# Video player
-keep class video_player.** { *; }
-dontwarn video_player.**

# Camera
-keep class camera.** { *; }
-dontwarn camera.**

# Socket.IO
-keep class socket_io_client.** { *; }
-dontwarn socket_io_client.**

# Keep model classes
-keep class com.sociallive.app.models.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep serialization classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}