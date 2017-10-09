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
    
    // Recording
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var banner: UIButton!
    @IBOutlet weak var bannerHeight: NSLayoutConstraint!
    @IBOutlet weak var activityViewWidth: NSLayoutConstraint!
    @IBOutlet weak var activityViewHeight: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIProgressView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareAudioSession()
        prepareAudioRecorder()
        prepareProximityMonitoring()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
            EvernoteIntegration.authenticate(with: self) { error in
                if let error = error {
                    self.alert(title: "Error", message: error.localizedDescription)
                    return
                }
                self.showActivity()
                do {
                    try EvernoteIntegration.send(audioURL: self.audioURL) { (noteRef, error) in
                        if let error = error { print(error.localizedDescription) }
                        self.noteRef = noteRef
                        self.showBanner(text: "Upload complete. Tap here to open in Evernote.")
                        self.hideActivity()
                        self.topButton.setImage(self.settings, for: .normal)
                        self.bottomButton.setImage(self.rec, for: .normal)
                    }
                } catch EvernoteIntegrationError.audioFileToData {
                    self.alert(title: "Export failed", message: "Audio file could not be converted to Data type.")
                } catch EvernoteIntegrationError.dataToResource {
                    self.alert(title: "Export failed", message: "Audio file could not be attached to note.")
                } catch {
                    self.alert(title: "Unknown error", message: "Please try again.")
                }
            }

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
}
    
// MARK: - General Helpers
extension ViewController {
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

