package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
    flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.cloudfirestore.CloudFirestorePlugin());
    flutterEngine.getPlugins().add(new com.mr.flutter.plugin.filepicker.FilePickerPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.firebaseanalytics.FirebaseAnalyticsPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.core.FirebaseCorePlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.crashlytics.firebasecrashlytics.FirebaseCrashlyticsPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.firebasedynamiclinks.FirebaseDynamicLinksPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.firebaseremoteconfig.FirebaseRemoteConfigPlugin());
    flutterEngine.getPlugins().add(new com.gonoter.flutter_beep.FlutterBeepPlugin());
      com.arthenica.flutter.ffmpeg.FlutterFFmpegPlugin.registerWith(shimPluginRegistry.registrarFor("com.arthenica.flutter.ffmpeg.FlutterFFmpegPlugin"));
    flutterEngine.getPlugins().add(new com.jrai.flutter_keyboard_visibility.FlutterKeyboardVisibilityPlugin());
    flutterEngine.getPlugins().add(new com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin());
      io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin.registerWith(shimPluginRegistry.registrarFor("io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin"));
    flutterEngine.getPlugins().add(new com.it_nomads.fluttersecurestorage.FlutterSecureStoragePlugin());
    flutterEngine.getPlugins().add(new com.dooboolab.fluttersound.FlutterSound());
      io.jojodev.flutter.flutteruseragent.FlutterUserAgentPlugin.registerWith(shimPluginRegistry.registrarFor("io.jojodev.flutter.flutteruseragent.FlutterUserAgentPlugin"));
    flutterEngine.getPlugins().add(new vn.hunghd.flutter.plugins.imagecropper.ImageCropperPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.imagepicker.ImagePickerPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.packageinfo.PackageInfoPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.pathprovider.PathProviderPlugin());
    flutterEngine.getPlugins().add(new com.baseflow.permissionhandler.PermissionHandlerPlugin());
    flutterEngine.getPlugins().add(new top.kikt.imagescanner.ImageScannerPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.share.SharePlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin());
    flutterEngine.getPlugins().add(new com.tekartik.sqflite.SqflitePlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.urllauncher.UrlLauncherPlugin());
    flutterEngine.getPlugins().add(new com.benjaminabel.vibration.VibrationPlugin());
    flutterEngine.getPlugins().add(new com.example.video_compress.VideoCompressPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.videoplayer.VideoPlayerPlugin());
      xyz.justsoft.video_thumbnail.VideoThumbnailPlugin.registerWith(shimPluginRegistry.registrarFor("xyz.justsoft.video_thumbnail.VideoThumbnailPlugin"));
    flutterEngine.getPlugins().add(new creativemaybeno.wakelock.WakelockPlugin());
  }
}
