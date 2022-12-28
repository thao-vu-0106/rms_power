import Flutter
import UIKit

public class SwiftRmsPowerPlugin: NSObject, FlutterPlugin {
    override init() {
        super.init()
    }
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "rms_power", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "rms_power_event", binaryMessenger: registrar.messenger())
        let instance = SwiftRmsPowerPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(RmsPowerProcess.shared())
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkPermission":
            result(RmsPowerProcess.shared().checkPermission())
        case "requestPermission":
            RmsPowerProcess.shared().requestPermission(result)
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "startRecorder":
            RmsPowerProcess.shared().startRecorder(result)
        case "stopRecorder":
            RmsPowerProcess.shared().stopRecorder(result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
