import 'rms_power_platform_interface.dart';

class RmsPower {
  Stream<double> get onRecorderStateChanged =>
      RmsPowerPlatform.instance.onRecorderStateChanged;

  Future<String?> getPlatformVersion() {
    return RmsPowerPlatform.instance.getPlatformVersion();
  }

  Future<void> requestPermission() async {
    return RmsPowerPlatform.instance.requestPermission();
  }

  Future<bool> checkPermission() async {
    return RmsPowerPlatform.instance.checkPermission();
  }

  Future<String?> stopRecorder() {
    return RmsPowerPlatform.instance.stopRecorder();
  }

  Future<String?> startRecorder() {
    return RmsPowerPlatform.instance.startRecorder();
  }
}
