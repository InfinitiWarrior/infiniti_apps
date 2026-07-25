package com.infinitiwarrior.musicplayer

import android.app.Activity
import android.content.ContentUris
import android.content.Intent
import android.os.Build
import android.provider.MediaStore
import androidx.annotation.NonNull
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// AudioServiceActivity is itself a FlutterActivity subclass (just_audio_background's
// dependency) — extending it wires up the notification/lock-screen media controls
// without needing to repoint AndroidManifest.xml's activity at the plugin's own class.
class MainActivity : AudioServiceActivity() {
    private val mediaStoreChannelName = "com.infinitiwarrior.musicplayer/media_store"
    private val deleteRequestCode = 4201
    private var pendingDeleteResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mediaStoreChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "deleteAudio" -> {
                        val rawIds = call.argument<List<*>>("ids") ?: emptyList<Any>()
                        deleteAudio(rawIds.map { (it as Number).toLong() }, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // Device-scanned tracks aren't files this app created, so scoped storage
    // (Android 10+) doesn't let it delete them directly. On API 30+,
    // MediaStore.createDeleteRequest shows the OS's own confirmation dialog
    // covering the whole batch at once — the user either allows deleting all
    // of them or cancels, there's no partial grant. Older devices fall back
    // to a best-effort direct delete (not this app's real target device).
    private fun deleteAudio(ids: List<Long>, result: MethodChannel.Result) {
        if (ids.isEmpty()) {
            result.success(false)
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val uris = ids.map {
                ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, it)
            }
            val pendingIntent = MediaStore.createDeleteRequest(contentResolver, uris)
            pendingDeleteResult = result
            startIntentSenderForResult(
                pendingIntent.intentSender,
                deleteRequestCode,
                null,
                0,
                0,
                0,
                null,
            )
        } else {
            var allDeleted = true
            for (id in ids) {
                val uri = ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id)
                try {
                    if (contentResolver.delete(uri, null, null) <= 0) allDeleted = false
                } catch (e: SecurityException) {
                    allDeleted = false
                }
            }
            result.success(allDeleted)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == deleteRequestCode) {
            pendingDeleteResult?.success(resultCode == Activity.RESULT_OK)
            pendingDeleteResult = null
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
}
