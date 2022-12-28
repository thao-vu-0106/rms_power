import UIKit
import Flutter
import AVFoundation
import AVFAudio

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      let audioSession = AVAudioSession.sharedInstance()
        do {
         try audioSession.setActive(true)
         try audioSession.setCategory(.playAndRecord, mode: .default,options: [.allowBluetooth, .defaultToSpeaker])
        } catch let error as NSError {
         print(error.description)
        } catch {
        }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
