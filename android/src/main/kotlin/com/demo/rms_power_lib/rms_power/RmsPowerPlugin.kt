package com.demo.rms_power_lib.rms_power

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/** RmsPowerPlugin */
class RmsPowerPlugin : FlutterPlugin, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var activity: ActivityPluginBinding? = null
    private var handler: RmsPowerProcess? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "rms_power")
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "rms_power_event")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)

    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding
        handler = RmsPowerProcess(activity!!.activity)
        activity!!.addRequestPermissionsResultListener(handler!!)
        methodChannel.setMethodCallHandler(handler)
        eventChannel.setStreamHandler(handler)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        activity?.removeRequestPermissionsResultListener(handler!!)
        handler = null
        activity = null
    }
}
