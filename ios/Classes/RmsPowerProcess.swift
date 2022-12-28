//
//  RmsPowerProcess.swift
//  rms_power
//
//  Created by Thao Vu Duc on 27/12/2022.
//

import Foundation
import AVFoundation
import AudioToolbox

private func AudioQueueInputCallback(
    _ inUserData: UnsafeMutableRawPointer?,
    inAQ: AudioQueueRef,
    inBuffer: AudioQueueBufferRef,
    inStartTime: UnsafePointer<AudioTimeStamp>,
    inNumberPacketDescriptions: UInt32,
    inPacketDescs: UnsafePointer<AudioStreamPacketDescription>?)
{
    // Do nothing, because not recoding.
}

public class RmsPowerProcess: NSObject, FlutterStreamHandler {
    private static var sharedRmsPowerProcess: RmsPowerProcess = {
            let networkManager = RmsPowerProcess()
            return networkManager
        }()
    
    class func shared() -> RmsPowerProcess {
            return sharedRmsPowerProcess
        }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    var queue: AudioQueueRef!
    var timer: Timer!
    
    private var eventSink: FlutterEventSink? = nil
    private var isStarted = false
    
    func requestPermission(_ result: @escaping FlutterResult) {
        AVCaptureDevice.requestAccess(for: .audio, completionHandler: {result($0)})
    }
    
    func checkPermission() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .notDetermined:
            return false
        case .authorized:
            return true
        default:
            return false
        }
    }
    
    func startRecorder(_ result: @escaping FlutterResult) {
        if (self.isStarted) {
            return
        }
        var dataFormat = AudioStreamBasicDescription(
            mSampleRate: 44100.0,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: AudioFormatFlags(kLinearPCMFormatFlagIsBigEndian | kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked),
            mBytesPerPacket: 2,
            mFramesPerPacket: 1,
            mBytesPerFrame: 2,
            mChannelsPerFrame: 1,
            mBitsPerChannel: 16,
            mReserved: 0)
        var audioQueue: AudioQueueRef? = nil
        var error = noErr
        error = AudioQueueNewInput(
            &dataFormat,
            AudioQueueInputCallback,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            .none,
            .none,
            0,
            &audioQueue)
        if error == noErr {
            self.queue = audioQueue
        }
        AudioQueueStart(self.queue, nil)
        
        // Enable level meter
        var enabledLevelMeter: UInt32 = 1
        AudioQueueSetProperty(self.queue, kAudioQueueProperty_EnableLevelMetering, &enabledLevelMeter, UInt32(MemoryLayout<UInt32>.size))
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.05,
                                          target: self,
                                          selector: #selector(RmsPowerProcess.detectVolume(_:)),
                                          userInfo: nil,
                                          repeats: true)
        self.timer?.fire()
        self.isStarted = true
        result("recorder start")
    }
    
    func stopRecorder(_ result: @escaping FlutterResult) {
        if (self.timer != nil) {
            self.timer.invalidate()
        }
        self.timer = nil
        AudioQueueFlush(self.queue)
        AudioQueueStop(self.queue, false)
        AudioQueueDispose(self.queue, true)
        self.isStarted = false
        result("recorder stop")
    }
    
    @objc func detectVolume(_ timer: Timer)
    {
        // Get level
        var levelMeter = AudioQueueLevelMeterState()
        var propertySize = UInt32(MemoryLayout<AudioQueueLevelMeterState>.size)
        
        AudioQueueGetProperty(
            self.queue,
            kAudioQueueProperty_CurrentLevelMeterDB,
            &levelMeter,
            &propertySize)
        
        // Show the audio channel's peak and average RMS power.
        eventSink?(levelMeter.mPeakPower)
    }
}
