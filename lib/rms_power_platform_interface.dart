import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'rms_power_method_channel.dart';

abstract class RmsPowerPlatform extends PlatformInterface {
  /// Constructs a RmsPowerPlatform.
  RmsPowerPlatform() : super(token: _token);

  static final Object _token = Object();

  static RmsPowerPlatform _instance = MethodChannelRmsPower();

  /// The default instance of [RmsPowerPlatform] to use.
  ///
  /// Defaults to [MethodChannelRmsPower].
  static RmsPowerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RmsPowerPlatform] when
  /// they register themselves.
  static set instance(RmsPowerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
  Stream<double> get onRecorderStateChanged;

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> checkPermission() {
    throw UnimplementedError('checkPermission() has not been implemented.');
  }

  Future<void> requestPermission() {
    throw UnimplementedError('requestPermission() has not been implemented.');
  }

  Future<String?> stopRecorder() {
    throw UnimplementedError('stopRecorder() has not been implemented.');
  }

  Future<String?> startRecorder() {
    throw UnimplementedError('startRecorder() has not been implemented.');
  }
}
