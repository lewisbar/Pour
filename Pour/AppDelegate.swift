//
//  AppDelegate.swift
//  Pour
//
//  Created by Lennart Wisbar on 28.09.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit
import EvernoteSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        ENSession.setSharedSessionConsumerKey(Keys.Evernote.key, consumerSecret: Keys.Evernote.secret, optionalHost: ENSessionHostSandbox)
        
        // Override point for customization after application launch.
        // TODO: Restore state

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        pause()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        pause()
        // TODO: Save state
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        // TODO: Restore state?
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // TODO: Restore state?
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        pause()
        // TODO: Save state
    }

    private func pause() {
        // Pause recording or playback
        if let vc = window?.rootViewController as? ViewController {
            if let isRecording = vc.audio.recorder?.isRecording,
                isRecording {
                vc.audio.pauseRecording()
                vc.state = .recordingPaused
            } /*else if let isPlaying = vc.audio.player?.isPlaying,
             isPlaying {
             vc.audio.pausePlayback()
             vc.state = .playbackPaused
             }*/
        }
    }

}

