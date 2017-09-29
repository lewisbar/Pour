//
//  ViewController.swift
//  Pour
//
//  Created by Lennart Wisbar on 28.09.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    // MARK: - Properties
    // Recording
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    var audioSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var isRecordingAllowed = false
    lazy var audioURL = getDocumentsDirectory().appendingPathComponent("recording.m4a", isDirectory: false)
    
    // Images
    let settings =  #imageLiteral(resourceName: "Settings Button")
    let rec = #imageLiteral(resourceName: "Rec Button")
    let stopRecording = #imageLiteral(resourceName: "Stop Button")
    let pauseRecording = #imageLiteral(resourceName: "Pause Recording Button")
    let unpauseRecording = #imageLiteral(resourceName: "Unpause Recording Button")
    let play = #imageLiteral(resourceName: "Play Button")
    let pausePlayback = #imageLiteral(resourceName: "Pause Playback Button")
    let unpausePlayback = #imageLiteral(resourceName: "Unpause Playback Button")
    let delete = #imageLiteral(resourceName: "Delete Button")
    let evernote = #imageLiteral(resourceName: "Evernote Button")
    let dropbox = #imageLiteral(resourceName: "Dropbox Button")
    
    // MARK: - Preparation on launch
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareAudioSession()
        prepareAudioRecorder()
        prepareProximityMonitoring()
    }
    
    private func prepareAudioSession() {
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
    
    private func prepareAudioRecorder() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
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
    
    private func prepareProximityMonitoring() {
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = true
        if device.isProximityMonitoringEnabled {
            NotificationCenter.default.addObserver(self, selector: #selector(handleProximityChange), name: NSNotification.Name.UIDeviceProximityStateDidChange, object: nil)
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Pressed
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let currentImage = sender.image(for: .normal) else {
            print("Button can't be identified. Image missing.")
            return
        }
        
        switch currentImage {
            
        // Settings
        case settings:
            print("Settings screen not implemented yet")
            
        // Recording
        case rec:
            if isRecordingAllowed {
                audioRecorder?.record()
                topButton.setImage(self.pauseRecording, for: .normal)
                bottomButton.setImage(self.stopRecording, for: .normal)
            } else {
                self.alert(title: "Microphone Access Denied", message: "Seems like you denied microphone permission. You can allow microphone access under Settings > Privacy > Microphone.")
            }
        case pauseRecording:
            audioRecorder?.pause()
            topButton.setImage(unpauseRecording, for: .normal)
        case unpauseRecording:
            audioRecorder?.record()
            topButton.setImage(pauseRecording, for: .normal)
        case stopRecording:
            finishRecording(success: true)
            topButton.setImage(delete, for: .normal)
            bottomButton.setImage(play, for: .normal)
            preparePlayback()
            
        // Playback
        case play:
            audioPlayer?.play()
            bottomButton.setImage(pausePlayback, for: .normal)
        case pausePlayback:
            audioPlayer?.pause()
            bottomButton.setImage(unpausePlayback, for: .normal)
        case unpausePlayback:
            audioPlayer?.play()
            bottomButton.setImage(pausePlayback, for: .normal)
            
        // Deletion
        case delete:
            audioPlayer?.stop()
            // audioRecorder?.deleteRecording() // File gets overridden by prepareToRecord()
            audioRecorder?.prepareToRecord()
            topButton.setImage(settings, for: .normal)
            bottomButton.setImage(rec, for: .normal)
            
        // Export
        case evernote:
            print("Evernote export not implemented yet.")
            topButton.setImage(settings, for: .normal)
            bottomButton.setImage(rec, for: .normal)
        case dropbox:
            print("Dropbox export not implemented yet.")
            topButton.setImage(settings, for: .normal)
            bottomButton.setImage(rec, for: .normal)
            
        // Default
        default:
            print("Button can't be identified. Unknown image.")
            break
        }
    }
    
    private func preparePlayback() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        }
        catch {
            alert(title: "File could not be opened", message: "Please contact RecFlow support")
            topButton.setImage(settings, for: .normal)
            bottomButton.setImage(rec, for: .normal)
        }
    }
    
    private func finishRecording(success: Bool) {
        audioRecorder?.stop()
        
        if success {
            // print("Recording finished successfully")
        } else {
            alert(title: "Recording failed", message: "Please contact RecFlow support")
            topButton.setImage(settings, for: .normal)
            bottomButton.setImage(rec, for: .normal)
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        bottomButton.setImage(play, for: .normal)
    }
}

// MARK: - General Helpers
extension ViewController {
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

