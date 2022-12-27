import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'rms_power_platform_interface.dart';

/// An implementation of [RmsPowerPlatform] that uses method channels.
class MethodChannelRmsPower extends RmsPowerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('rms_power');
  final eventChannel = const EventChannel('rms_power_event');

  @override
  Stream<double> get onRecorderStateChanged => eventChannel
      .receiveBroadcastStream()
      .distinct()
      .map((event) => event as double);

  bool _isRecording = false;

  bool get getIsRecording => _isRecording;

  set setIsRecording(bool isRecording) => _isRecording = isRecording;

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> requestPermission() async {
    await methodChannel.invokeMethod<String>('requestPermission');
  }

  @override
  Future<bool> checkPermission() async {
    final state = await methodChannel.invokeMethod<bool>('requestPermission');
    return state ?? false;
  }

  @override
  Future<String?> stopRecorder() {
    if (!getIsRecording) {
      throw RecorderStoppedException("Recorder is not running.");
    }
    return super.stopRecorder();
  }

  @override
  Future<String?> startRecorder() async {
    if (getIsRecording) {
      throw RecorderRunningException("Recorder is already running.");
    }

    try {
      String result = await methodChannel.invokeMethod('startRecorder');
      setIsRecording = true;
      return result;
    } catch (err) {
      throw Exception(err);
    }
  }
}

class RecorderRunningException implements Exception {
  final String message;

  RecorderRunningException(this.message);
}

class RecorderStoppedException implements Exception {
  final String message;

  RecorderStoppedException(this.message);
}
