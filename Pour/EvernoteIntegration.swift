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
