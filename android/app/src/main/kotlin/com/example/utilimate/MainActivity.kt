// android/app/src/main/kotlin/com/example/utilimate/MainActivity.kt
package com.example.utilimate

import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.utilimate/media_scanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "scanFile") {
                val path = call.argument<String>("path")
                if (path != null) {
                    scanFile(this, path)
                    result.success(null) // Indicate success, no return value
                } else {
                    result.error("INVALID_ARGUMENT", "File path cannot be null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun scanFile(context: Context, filePath: String) {
        MediaScannerConnection.scanFile(
            context,
            arrayOf(filePath),
            null // MimeType can be null, MediaScanner will infer
        ) { path, uri ->
            // You can log here if needed, but not strictly necessary for functionality
            // Log.d("MediaScanner", "Scanned $path: $uri")
        }
    }
}