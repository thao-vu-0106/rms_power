import 'package:flutter_test/flutter_test.dart';
import 'package:rms_power/rms_power.dart';
import 'package:rms_power/rms_power_platform_interface.dart';
import 'package:rms_power/rms_power_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRmsPowerPlatform
    with MockPlatformInterfaceMixin
    implements RmsPowerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> checkPermission() {
    return Future(() => true);
  }

  @override
  Future<void> requestPermission() {
    return Future(() => null);
  }

  @override
  Future<String?> startRecorder() {
    return Future(() => null);
  }

  @override
  Future<String?> stopRecorder() {
    return Future(() => null);
  }

  @override
  Stream<double> get onRecorderStateChanged => Stream.value(0.0);
}

void main() {
  final RmsPowerPlatform initialPlatform = RmsPowerPlatform.instance;

  test('$MethodChannelRmsPower is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRmsPower>());
  });

  test('getPlatformVersion', () async {
    RmsPower rmsPowerPlugin = RmsPower();
    MockRmsPowerPlatform fakePlatform = MockRmsPowerPlatform();
    RmsPowerPlatform.instance = fakePlatform;

    expect(await rmsPowerPlugin.getPlatformVersion(), '42');
  });
}
