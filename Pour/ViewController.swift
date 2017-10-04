//
//  ViewController.swift
//  Pour
//
//  Created by Lennart Wisbar on 28.09.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit
import AVFoundation
import EvernoteSDK

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    // TODO: Preserve ViewController state when the app is closed
    // (otherwise you're not able to get to a not-yet-deleted recording because the start screen is shown)
    
    // MARK: - Properties
    // Recording
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var banner: UIButton!
    @IBOutlet weak var bannerHeight: NSLayoutConstraint!
    var audioSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var isRecordingAllowed = false
    lazy var audioURL = getDocumentsDirectory().appendingPathComponent("recording.m4a", isDirectory: false)
    
    var noteRef: ENNoteRef?
    
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
    
    private func prepareProximityMonitoring() {
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
                UIDevice.current.isProximityMonitoringEnabled = true
            } else {
                self.alert(title: "Microphone Access Denied", message: "Seems like you denied microphone permission. You can allow microphone access under Settings > Privacy > Microphone.")
            }
        case pauseRecording:
            audioRecorder?.pause()
            UIDevice.current.isProximityMonitoringEnabled = false
            topButton.setImage(unpauseRecording, for: .normal)
        case unpauseRecording:
            audioRecorder?.record()
            UIDevice.current.isProximityMonitoringEnabled = true
            topButton.setImage(pauseRecording, for: .normal)
        case stopRecording:
            finishRecording(success: true)
            UIDevice.current.isProximityMonitoringEnabled = false
            topButton.setImage(delete, for: .normal)
            bottomButton.setImage(evernote, for: .normal)
            preparePlayback()
            
//        // Playback
//        case play:
//            audioPlayer?.play()
//            UIDevice.current.isProximityMonitoringEnabled = true
//            bottomButton.setImage(pausePlayback, for: .normal)
//        case pausePlayback:
//            audioPlayer?.pause()
//            UIDevice.current.isProximityMonitoringEnabled = false
//            bottomButton.setImage(unpausePlayback, for: .normal)
//        case unpausePlayback:
//            audioPlayer?.play()
//            UIDevice.current.isProximityMonitoringEnabled = true
//            bottomButton.setImage(pausePlayback, for: .normal)
            
        // Deletion
        case delete:
            audioPlayer?.stop()
            UIDevice.current.isProximityMonitoringEnabled = false
            // audioRecorder?.deleteRecording() // File gets overridden by prepareToRecord() anyway
            audioRecorder?.prepareToRecord()
            topButton.setImage(settings, for: .normal)
            bottomButton.setImage(rec, for: .normal)
            
        // Export
        case evernote:
            authentificateEvernote()
            sendToEvernote()
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
            alert(title: "File could not be opened", message: "Please contact Pour support")
            topButton.setImage(settings, for: .normal)
            bottomButton.setImage(rec, for: .normal)
        }
    }
    
    private func finishRecording(success: Bool) {
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
    
    // MARK: - Evernote Integration
    private func authentificateEvernote() {
        if !ENSession.shared.isAuthenticated {
            ENSession.shared.authenticate(with: self, preferRegistration: false, completion: {
                error in
                if let error = error {
                    self.alert(title: "Authentification failed", message: "Please try again.")
                    print(error.localizedDescription)
                    return
                }
            })
        }
    }
    
    private func sendToEvernote() {
        do {
            let note = ENNote()
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd [hh:mm]"
            let title = formatter.string(from: date)
            note.title = title
            
            let data = try Data(contentsOf: audioURL)
            let filename = title + ".m4a"
            let resource = ENResource(data: data, mimeType: "audio/mp4a-latm", filename: filename)
            note.add(resource!)
            // note.content = ENNoteContent(string: "This is my fourth note. I wonder if this works.")
            ENSession.shared.upload(note, notebook: nil, completion: { (noteRef, error) in
                if let error = error { print(error.localizedDescription) }
                self.noteRef = noteRef
                self.showBanner(text: "Upload complete. Tap here to open in Evernote.")
            })
        } catch {
            print("Recording file cannot be converted to Data type")
            alert(title: "Export failed", message: "Recording file cannot be converted to Data type.")
        }
    }
    
    private func showBanner(text: String) {
        let showDuration = 3.0
        banner.titleLabel?.adjustsFontSizeToFitWidth = true
        banner.setTitle(text, for: .normal)
        banner.backgroundColor = .darkGray
        banner.alpha = 1

        // Animate banner expansion
        UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
            self.bannerHeight.constant = 64 // TODO: Don't hardcode
            self.view.layoutIfNeeded()
            self.banner.backgroundColor = .black
        }, completion: { finished in
            // Tappable phase
            UIView.animate(withDuration: 0.01, delay: showDuration, options: .allowUserInteraction, animations: {
                self.banner.backgroundColor = .darkGray
            }, completion: { finished in
                // Animate disappearing banner
                UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                    self.bannerHeight.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.banner.alpha = 0
                })
            })
        })
    }
    
    @IBAction func bannerTouched(_ sender: UIButton) {
        print("banner touched")
        if let noteRef = noteRef {
            print("noteRef exists")
            ENSession.shared.viewNoteInEvernote(noteRef)
        }
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

