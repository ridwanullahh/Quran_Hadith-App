package com.minhaajulhudaa.quran

import io.flutter.embedding.android.FlutterFragmentActivity

// IMPORTANT: must extend FlutterFragmentActivity (not FlutterActivity).
//
// flutter_local_notifications requires a FragmentActivity to show the
// Android 13+ POST_NOTIFICATIONS permission dialog. With the default
// FlutterActivity, the plugin throws on startup:
//
//   PlatformException(The Activity class declared in your AndroidManifest.xml
//   is wrong or has not provided the correct FlutterEngine. Please see the
//   README for instructions., null, null, null)
//
// Other plugins that benefit from FragmentActivity:
//   - permission_handler (location, notifications, microphone dialogs)
//   - image_picker / file_picker (chooser intents)
//   - in_app_purchase (Play Billing UI)
//
// See: https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications#android-manifest-setup
class MainActivity : FlutterFragmentActivity()
