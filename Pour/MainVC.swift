//
//  MainVC.swift
//  Pour
//
//  Created by Lennart Wisbar on 28.09.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit
import AVFoundation
import EvernoteSDK

class MainVC: UIViewController {
    
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
    
    let topButton = UIButton(type: .custom)
    let bottomButton = UIButton(type: .custom)
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    var activityViewWidth: NSLayoutConstraint!
    var activityViewHeight: NSLayoutConstraint!
    let banner = UIButton(type: .custom)
    var bannerHeight: NSLayoutConstraint!
    let audio = Audio()
    var safeAreaTopInset: CGFloat!
    
    override var prefersStatusBarHidden: Bool {
        // This somehow fixes the status bar pushing the settings view down just before the dismiss transition. It was intended to not let it appear until the main view is far enough down, but what actually happens is that it still appears at the start of the transition, but doesn't affect the settings view's position. That's fine.
        return (view.frame.origin.y > UIScreen.main.bounds.height / 3)
    }
    
    var noteRef: ENNoteRef?
    
    // Images
    let settings = #imageLiteral(resourceName: "Settings Button")
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
        
        topButton.setImage(settings, for: .normal)
        bottomButton.setImage(rec, for: .normal)
        topButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        bottomButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        banner.backgroundColor = .black
        banner.titleLabel?.textColor = .white
        banner.addTarget(self, action: #selector(bannerTouched(_:)), for: .touchUpInside)
        
        // Set up view hierarchy
        let background = UIView()
        let topBackground = UIView()
        let bottomBackground = UIView()
        background.backgroundColor = .white
        topBackground.backgroundColor = .white
        bottomBackground.backgroundColor = .white
        // view.backgroundColor = .white
        view.backgroundColor = .clear
        topBackground.addSubview(topButton)
        bottomBackground.addSubview(bottomButton)
        background.addSubview(topBackground)
        background.addSubview(bottomBackground)
        view.addSubview(background)
        let line = UIImageView(image: #imageLiteral(resourceName: "Line"))
        view.addSubview(line)
        let activityView = UIView()
        activityView.backgroundColor = .white
        activityView.addSubview(activityIndicator)
        view.addSubview(activityView)
        view.addSubview(banner)
        
        // Layout
        background.translatesAutoresizingMaskIntoConstraints = false
        topBackground.translatesAutoresizingMaskIntoConstraints = false
        bottomBackground.translatesAutoresizingMaskIntoConstraints = false
        topButton.translatesAutoresizingMaskIntoConstraints = false
        bottomButton.translatesAutoresizingMaskIntoConstraints = false
        line.translatesAutoresizingMaskIntoConstraints = false
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        banner.translatesAutoresizingMaskIntoConstraints = false
        activityViewWidth = activityView.widthAnchor.constraint(equalToConstant: 0)
        activityViewHeight = activityView.heightAnchor.constraint(equalToConstant: 0)
        bannerHeight = banner.heightAnchor.constraint(equalToConstant: 0)

        // During the transition to SettingsVC, the status bar disappears, seemingly setting the safe area top inset to zero, which made the view jump up a bit. Therefore, I can't simply use view.safeAreaLayoutGuide.topAnchor. The solution I found is to get the safeAreaLayoutGuide constant and use that constant directly, so it doesn't change when the safe area changes.
        if #available(iOS 11.0, *) {
            safeAreaTopInset = max(UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0, 20)
        } else {
            // Fallback on earlier versions
            safeAreaTopInset = 20
        }
        
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: view.topAnchor, constant: safeAreaTopInset),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBackground.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            topBackground.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            topBackground.topAnchor.constraint(equalTo: background.topAnchor),
            topBackground.bottomAnchor.constraint(equalTo: background.centerYAnchor),
            bottomBackground.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            bottomBackground.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            bottomBackground.topAnchor.constraint(equalTo: background.centerYAnchor),
            bottomBackground.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            topButton.centerXAnchor.constraint(equalTo: topBackground.centerXAnchor),
            topButton.centerYAnchor.constraint(equalTo: topBackground.centerYAnchor),
            bottomButton.centerXAnchor.constraint(equalTo: bottomBackground.centerXAnchor),
            bottomButton.centerYAnchor.constraint(equalTo: bottomBackground.centerYAnchor),
            line.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            line.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            activityView.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            activityView.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            activityViewWidth,
            activityViewHeight,
            activityIndicator.centerXAnchor.constraint(equalTo: activityView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: activityView.centerYAnchor),
            banner.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            banner.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            bannerHeight,
        ])
        
        do {
            try audio.prepareAudioSession()
            try audio.prepareAudioRecorder(url: getDocumentsDirectory().appendingPathComponent("recording.m4a", isDirectory: false))
            audio.prepareProximityMonitoring()
        } catch {
            alert(title: "Error", message: error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        guard let currentImage = sender.image(for: .normal) else {
            print("Button can't be identified. Image missing.")
            return
        }
        
        switch currentImage {
            
        // Settings
        case settings:
            let settingsVC = SettingsTVC()
            settingsVC.mainVCSafeAreaTopInset = safeAreaTopInset
            let nav = UINavigationController(rootViewController: settingsVC)
            nav.navigationBar.barTintColor = .black
            nav.navigationBar.tintColor = .white
            nav.navigationBar.isTranslucent = false
            nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.white]
            nav.transitioningDelegate = self
            nav.modalPresentationStyle = .custom
            nav.modalPresentationCapturesStatusBarAppearance = true
            present(nav, animated: true)
            
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
                
                guard let audioURL = self.audio.url else {
                    self.alert(title: "Error", message: "Recording not found")
                    return
                }
                let backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Upload to Evernote", expirationHandler: {
                    self.state = .recordingStopped
                    self.hideActivity()
                })
                do {
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
                UIApplication.shared.endBackgroundTask(backgroundTaskID)
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
extension MainVC {
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

