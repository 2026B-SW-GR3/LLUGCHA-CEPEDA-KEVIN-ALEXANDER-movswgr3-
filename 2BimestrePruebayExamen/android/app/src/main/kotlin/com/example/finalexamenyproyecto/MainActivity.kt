package com.example.finalexamenyproyecto

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.fitmap.intent"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "sendEvent") {
                    val action = call.argument<String>("action") ?: ""
                    val extras = call.argument<Map<String, Any>>("extras") ?: emptyMap()

                    val intent = Intent(action).apply {
                        extras.forEach { (key, value) ->
                            when (value) {
                                is String -> putExtra(key, value)
                                is Int -> putExtra(key, value)
                                is Double -> putExtra(key, value)
                                is Boolean -> putExtra(key, value)
                                else -> putExtra(key, value.toString())
                            }
                        }
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    }

                    // Show app chooser if multiple apps can handle the intent
                    val chooser = Intent.createChooser(intent, "Enviar a...")
                    startActivity(chooser)
                } else {
                    result.notImplemented()
                }
            }
    }
}
