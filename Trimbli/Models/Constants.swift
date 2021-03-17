//
//  Constants.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 06/10/2020.
//

import UIKit

struct Constants {
    static let collectionName = "songs"
    static let segueToPreview = "goToPreview"
    
    struct FirebaseSongAttributes {
        static let songID: String = "songID"
        static let isDownloaded: String = "isDownloaded"
    }
    
    struct RemoteRelated {
        static let containerForSearch = "containerForSearch"
        static let remoteSongCell = "RemoteSongCell"
    }
    
    struct LocalRelated {
        static let containerForLibrary = "containerForLibrary"
        static let localSongCell = "LocalSongCell"
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

enum AudioSourceConfiguration {
    case localConfiguration
    case remoteConfiguration
}

enum Replaying {
    case notRepeating
    case repeating
    case repeatingOnlyOne
}

extension Notification.Name {
    static let loading = Notification.Name(rawValue: "loading")
    static let readyForRefresh = Notification.Name(rawValue: "readyForRefresh")
    static let selectedRemote = Notification.Name(rawValue: "selectedRemote")
    static let selectedLocal = Notification.Name(rawValue: "selectedLocal")
    static let progressObservation = Notification.Name(rawValue: "progressObservation")
    static let updateUI = Notification.Name(rawValue: "updateUI")
}

extension UIImage {
    static let largeConfiguration = UIImage.SymbolConfiguration(scale: .large)
    static let mediumConfiguration = UIImage.SymbolConfiguration(scale: .medium)
    static let smallConfiguration = UIImage.SymbolConfiguration(scale: .small)
    static let circleFillSmall = UIImage(systemName: "circle.fill", withConfiguration: UIImage.smallConfiguration)
    static let circleFillMedium = UIImage(systemName: "circle.fill", withConfiguration: UIImage.mediumConfiguration)
    static let shuffleIsNotActive = UIImage(named: "shuffle_button_notActive")
    static let shuffleIsActive = UIImage(named: "shuffle_button_active")
    static let play = UIImage(named: "play_button")
    static let pause = UIImage(named: "pause_button")
    static let replayIsNotRepeating = UIImage(named: "replay_button_notRepeating")
    static let replayIsRepeating = UIImage(named: "replay_button_repeating")
    static let replayIsRepeatingOnlyOne = UIImage(named: "replay_button_repeatingOnlyOne")
}

extension UIImageView {
    func blurImage() {
        let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
        blurredView.frame = self.bounds
        blurredView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurredView)
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension UIColor {
    static let accentColor = UIColor(named: "AccentColor")
    static let listColor = UIColor(named: "ListColor")!
}
