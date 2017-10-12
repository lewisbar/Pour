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

class ViewController: UIViewController {
    
    // TODO: Preserve ViewController state when the app is closed
    // (otherwise you're not able to get to a not-yet-deleted recording because the start screen is shown)
    
    enum State {
        case readyToRecord
        case recording
        case recordingPaused
        case recordingStopped
    }
    
    var state: State = .readyToRecord {
        didSet {
            switch state {
            case .readyToRecord:
                topButton.setImage(settings, for: .normal)
                bottomButton.setImage(rec, for: .normal)
            case .recording:
                topButton.setImage(pauseRecording, for: .normal)
                bottomButton.setImage(stopRecording, for: .normal)
            case .recordingPaused:
                topButton.setImage(unpauseRecording, for: .normal)
                bottomButton.setImage(stopRecording, for: .normal)
            case .recordingStopped:
                topButton.setImage(delete, for: .normal)
                bottomButton.setImage(evernote, for: .normal)
            }
        }
    }
    
    // Recording
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var banner: UIButton!
    @IBOutlet weak var bannerHeight: NSLayoutConstraint!
    @IBOutlet weak var activityViewWidth: NSLayoutConstraint!
    @IBOutlet weak var activityViewHeight: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIProgressView!
    let audio = Audio()
    
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
        
        do {
            try audio.prepareAudioSession()
            try audio.prepareAudioRecorder(url: getDocumentsDirectory().appendingPathComponent("recording.m4a", isDirectory: false)
)
            audio.prepareProximityMonitoring()
        } catch {
            alert(title: "Error", message: error.localizedDescription)
        }
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
            do {
                try audio.record()
                state = .recording
            } catch {
                alert(title: "Error", message: error.localizedDescription)
            }

        case pauseRecording:
            audio.pauseRecording()
            state = .recordingPaused
        case unpauseRecording:
            audio.unpauseRecording()
            state = .recording
        case stopRecording:
            audio.stopRecording()
//            do {
//                try audio.preparePlayback()
//            } catch {
//                alert(title: "Error", message: error.localizedDescription)
//            }
            state = .recordingStopped
            
//        // Playback
//        case play:
//            audio.play()
//            bottomButton.setImage(pausePlayback, for: .normal)
//        case pausePlayback:
//            audio.pausePlayback()
//            bottomButton.setImage(unpausePlayback, for: .normal)
//        case unpausePlayback:
//            audio.unpausePlayback()
//            bottomButton.setImage(pausePlayback, for: .normal)
            
        // Deletion
        case delete:
            audio.stopPlayback()
            audio.deleteRecording()
            state = .readyToRecord
            
        // Export
        case evernote:
            EvernoteIntegration.authenticate(with: self) { error in
                if let error = error {
                    self.alert(title: "Error", message: error.localizedDescription)
                    return
                }
                self.showActivity()
                do {
                    guard let audioURL = self.audio.url else {
                        self.alert(title: "Error", message: "Recording not found")
                        return
                    }
                    try EvernoteIntegration.send(audioURL: audioURL) { (noteRef, error) in
                        if let error = error { print(error.localizedDescription) }
                        self.noteRef = noteRef
                        let preposition = EvernoteIntegration.evernoteHasFixedViewInEvernoteFunctionality ? " in" : ""
                        self.showBanner(text: "Upload complete. Tap here to open\(preposition) Evernote.")
                        self.hideActivity()
                        self.state = .readyToRecord
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
            state = .readyToRecord
            
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

