//
//  URLLocation.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 17.03.2021.
//

import Foundation

struct URLLocation {
    static func fetchURL(_ songID: String) -> URL? {
        return URL(string: "https://firebasestorage.googleapis.com/v0/b/trimbli-5ee28.appspot.com/o/\(songID)?alt=media")
    }
}
