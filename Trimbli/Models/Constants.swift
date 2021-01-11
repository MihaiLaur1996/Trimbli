//
//  Constants.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 06/10/2020.
//

import UIKit
import AVFoundation

struct Constants {
    static let path = "path.txt"
    static let collectionName = "songs"
    
    struct FirebaseSongAttributes {
        static let songID: String = "songID"
        static let isDownloaded: String = "isDownloaded"
    }
    
    struct RemoteRelated {
        static let containerForSearch = "containerForSearch"
        static let segueToRemote = "goToRemote"
        static let remoteSongCell = "RemoteSongCell"
    }
    
    struct LocalRelated {
        static let containerForLibrary = "containerForLibrary"
        static let segueToLocal = "goToLocal"
        static let localSongCell = "LocalSongCell"
    }
}

extension Notification.Name {
    static let writeToRealmDatabase = Notification.Name(rawValue: "writeToRealm")
    static let valueHasChanged = Notification.Name(rawValue: "valueChanged")
    static let setSelected = Notification.Name(rawValue: "setSelected")
}

extension UIImage {
    static let largeConfiguration = UIImage.SymbolConfiguration(scale: .large)
    static let mediumConfiguration = UIImage.SymbolConfiguration(scale: .medium)
    static let smallConfiguration = UIImage.SymbolConfiguration(scale: .small)
}
