//
//  ViewController+Audio.swift
//  Pour
//
//  Created by Lennart Wisbar on 09.10.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import AVFoundation
import UIKit

extension ViewController {
    
    func prepareAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
        var options: AVAudioSessionCategoryOptions = [.defaultToSpeaker, .allowBluetooth]
        if #available(iOS 10.0, *) {
            options.insert([.allowAirPlay, .allowBluetoothA2DP])
        }
        
        do {
            try audioSession?.setCategory(AVAudioSessionCategoryPlayAndRecord, with: options)
            try audioSession?.setActive(true)
            audioSession?.requestRecordPermission() { [unowned self] allowed in
                if allowed {
                    self.isRecordingAllowed = true
                } else {
                    self.alert(title: "Microphone Access Denied", message: "Seems like you denied microphone permission. To allow microphone access, go to Settings > Privacy > Microphone.")
                }
            }
        } catch {
            self.alert(title: "Recording failed", message: "Try restarting the app or contact RecFlow support.")
        }
    }
    
    func prepareAudioRecorder() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
        } catch {
            finishRecording(success: false)
        }
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
            try? audioSession?.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } else {
            // Speaker
            try? audioSession?.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        }
    }
    
    func preparePlayback() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        }
        catch {
            alert(title: "File could not be opened", message: "Please contact Pour support")
            topButton.setImage(settings, for: .normal)
            bottomButton.setImage(rec, for: .normal)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        
        if success {
            // print("Recording finished successfully")
        } else {
            alert(title: "Recording failed", message: "Please contact Pour support")
            topButton.setImage(settings, for: .normal)
            bottomButton.setImage(rec, for: .normal)
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        bottomButton.setImage(play, for: .normal)
    }
}
