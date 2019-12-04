//
//  EvernoteIntegration.swift
//  Pour
//
//  Created by Lennart Wisbar on 09.10.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import Foundation
import EvernoteSDK

enum EvernoteIntegrationError: Error {
    case audioFileToData
    case dataToResource
}

struct EvernoteIntegration {
    
    static let evernoteHasFixedViewInEvernoteFunctionality = false
    
    static func authenticate(with viewController: UIViewController, completion: @escaping ENSessionAuthenticateCompletionHandler) {
        if !ENSession.shared.isAuthenticated {
            ENSession.shared.authenticate(with: viewController, preferRegistration: false, completion: completion)
        } else {
            completion(nil)
        }
    }
    
    static func send(audioURL: URL, completion: @escaping ENSessionUploadNoteCompletionHandler) throws {
        let note = ENNote()
        let title = titleFromCurrentDate()
        let filename = title + ".m4a"
        guard let data = try? Data(contentsOf: audioURL) else {
            throw EvernoteIntegrationError.audioFileToData
        }
        guard let resource = ENResource(data: data, mimeType: "audio/mp4a-latm", filename: filename) else {
            throw EvernoteIntegrationError.dataToResource
        }
        
        note.title = title
        note.add(resource)
        
        ENSession.shared.upload(note, notebook: nil, completion: completion)
    }
    
    static func openInEvernote(_ noteRef: ENNoteRef) {
        // Try to open Evernote app
        let evernoteURL = URL(string: "en://")!
        if UIApplication.shared.canOpenURL(evernoteURL) {
            if evernoteHasFixedViewInEvernoteFunctionality {
                ENSession.shared.viewNoteInEvernote(noteRef)
            } else {
                UIApplication.shared.open(evernoteURL)
            }
            return
        }
        
        // Open note in browser
        let service = Keys.Evernote.service
        guard let shardID = ENSession.shared.user?.shardId else {
            print("No user logged in")
            return
        }
        let userID = ENSession.shared.userID
        guard let noteGuid = noteRef.guid else {
            print("No noteGuid")
            return
        }
        guard let url = URL(string: "https://\(service)/shard/\(shardID)/nl/\(userID)/\(noteGuid)/") else {
            print("URL scheme not valid")
            return
        }
        
        UIApplication.shared.open(url)
    }
}

extension EvernoteIntegration {
    private static func titleFromCurrentDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd [hh:mm]"
        let title = formatter.string(from: date)
        return title
    }
}
