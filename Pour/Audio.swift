//
//  Audio.swift
//  Pour
//
//  Created by Lennart Wisbar on 09.10.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import AVFoundation
import UIKit

enum AudioError: Error, LocalizedError {
    case microphoneAccessDenied
    case fileNotFound
    
    public var errorDescription: String? {
        switch self {
        case .microphoneAccessDenied:
            return NSLocalizedString("Seems like you denied microphone permission. You can allow microphone access under Settings > Privacy > Microphone.", comment: "User denied microphone access")
        case .fileNotFound:
            return NSLocalizedString("File not found", comment: "No file found at the specified URL")
        }
    }
}

class Audio/*: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate*/  {
    
    var session: AVAudioSession?
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    var url: URL?
    var isRecordingAllowed = false
    
    func prepareAudioSession() throws {
        var options: AVAudioSessionCategoryOptions = [.defaultToSpeaker, .allowBluetooth]
        if #available(iOS 10.0, *) {
            options.insert([.allowAirPlay, .allowBluetoothA2DP])
        }
        
        session = AVAudioSession.sharedInstance()
        try session?.setCategory(AVAudioSessionCategoryPlayAndRecord, with: options)
        try session?.setActive(true)
        session?.requestRecordPermission() { [unowned self] allowed in
            self.isRecordingAllowed = allowed
        }
    }
    
    func prepareAudioRecorder(url: URL) throws {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        self.url = url
        recorder = try AVAudioRecorder(url: url, settings: settings)
        //recorder?.delegate = self
        recorder?.prepareToRecord()
    }
    
    func preparePlayback() throws {
        guard let url = url else { throw AudioError.fileNotFound }
        player = try AVAudioPlayer(contentsOf: url)
        //player?.delegate = self
        player?.prepareToPlay()
    }
    
    func prepareProximityMonitoring() {
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = true
        if device.isProximityMonitoringEnabled {
            NotificationCenter.default.addObserver(self, selector: #selector(handleProximityChange), name: NSNotification.Name.UIDeviceProximityStateDidChange, object: nil)
        }
        device.isProximityMonitoringEnabled = false
    }
    
    @objc private func handleProximityChange(notification: Notification) {
        // Switch speakers
        if UIDevice.current.proximityState {
            // Receiver
            try? session?.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } else {
            // Speaker
            try? session?.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        }
    }
    
    func record() throws {
        guard isRecordingAllowed else { throw AudioError.microphoneAccessDenied }
        recorder?.record()
        UIDevice.current.isProximityMonitoringEnabled = true
    }
    
    func pauseRecording() {
        recorder?.pause()
        UIDevice.current.isProximityMonitoringEnabled = false
    }
    
    func unpauseRecording() {
        recorder?.record()
        UIDevice.current.isProximityMonitoringEnabled = true
    }
    
    func stopRecording() {
        recorder?.stop()
        UIDevice.current.isProximityMonitoringEnabled = false
    }
    
    func play() {
        player?.play()
        UIDevice.current.isProximityMonitoringEnabled = true
    }
    
    func pausePlayback() {
        player?.pause()
        UIDevice.current.isProximityMonitoringEnabled = false
    }
    
    func unpausePlayback() {
        player?.play()
        UIDevice.current.isProximityMonitoringEnabled = true
    }
    
    func stopPlayback() {
        player?.stop()
        UIDevice.current.isProximityMonitoringEnabled = false
    }
    
    func deleteRecording() {
        recorder?.prepareToRecord()
    }
    
//    // MARK: - AVAudioPlayerDelegate
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        bottomButton.setImage(play, for: .normal)
//    }
}
