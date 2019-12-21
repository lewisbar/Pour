//
//  BearIntegration.swift
//  Pour
//
//  Created by Lennart Wisbar on 21.12.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

enum BearIntegrationError: Error {
    case audioFileToData
    case invalidURL
}

struct BearIntegration {
    
    static func send(audioURL: URL, completion: @escaping () -> ()) throws {
        let title = Helpers.titleFromCurrentDate()
        let filename = title + ".m4a"
        guard let data = try? Data(contentsOf: audioURL) else {
            throw BearIntegrationError.audioFileToData
        }
        let base64Representation = data.base64EncodedString()
        if let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let encodedFilename = filename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let url = URL(string: "bear://x-callback-url/create?title=\(encodedTitle)&tags=musik%2Fsongwriting%2Cthemen%2Fmacht%2Cthemen%2Fsegen&file=\(base64Representation)&filename=\(encodedFilename)&open_note=yes") {
            UIApplication.shared.open(url) { _ in print("Done") }
        } else {
            throw BearIntegrationError.invalidURL
        }
    }
}
//"bear://x-callback-url/create?title=\(title)&tags=musik%2Fsongwriting%2Cthemen%2Fmacht%2Cthemen%2Fsegen&file=\(base64Representation)&filename=\(filename)&open_note=yes")
