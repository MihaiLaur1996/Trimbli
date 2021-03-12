//
//  MediaPlayer.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 16/10/2020.
//

import AVFoundation
import Firebase
import RealmSwift

class MediaPlayer {
    
    static let shared = MediaPlayer()
    var songs: [Song] = []
    var downloadedSongs: Results<DownloadedSong>!
    var chosenSong: String = ""
    var songIndex: IndexPath = IndexPath(index: 0)
    var progressValue: Float = 0.0
    var currentTime: String = "0:00"
    var totalDuration: String = ""
    var duration: Double = 0.0
    var playerItem: AVPlayerItem?
    var remotePlayer: AVPlayer?
    var localPlayer: AVAudioPlayer?
    var songArtwork: Data?
    var songTitle: String?
    var songArtist: String?
    var shuffleState: Bool = false
    var repeatState: Replaying = .notRepeating
    var audioSourceConfiguration: AudioSourceConfiguration?
    var progressTimer = Timer()
    var isPaused: Bool = false
    var playlistShuffled = [String]()
    var timeObserverToken: Any?
    var score = 0
    
    func playRemote(songName: String) {
        if let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/trimbli-dbd66.appspot.com/o/\(songName)?alt=media") {
            MediaPlayerLogic.shared.removePeriodicTimeObserver()
            playerItem = AVPlayerItem(url: url)
            if let playerItem = playerItem {
                DispatchQueue.global(qos: .background).async { [self] in
                    songArtist = getArtist(metadataList: fetchAssets(playerItem: playerItem))
                    songArtwork = getArtwork(metadataList: fetchAssets(playerItem: playerItem))
                    songTitle = getTitle(metadataList: fetchAssets(playerItem: playerItem))
                }
                remotePlayer = AVPlayer(playerItem: playerItem)
                remotePlayer?.playImmediately(atRate: 1.0)
                NotificationCenter.default.post(name: .progressObservation, object: nil)
            }
        }
    }
    
    func fetchURL(songID: String) -> URL? {
        return URL(string: "https://firebasestorage.googleapis.com/v0/b/trimbli-dbd66.appspot.com/o/\(songID)?alt=media")
    }
    
    func playLocal(songName: String) {
        if let storedURL = DataStorage.shared.documentDirectoryReference() {
            let completeURL = storedURL.appendingPathComponent(songName)
            do {
                localPlayer = try AVAudioPlayer(contentsOf: completeURL)
                localPlayer?.isMeteringEnabled = true
                localPlayer?.play()
            } catch {
                print(error)
            }
        }
    }
    
    func setAssetsLocal(songID: String) {
        if let storedURL = DataStorage.shared.documentDirectoryReference() {
            let completeURL = storedURL.appendingPathComponent(songID)
            let playerItem = AVPlayerItem(url: completeURL)
            songArtist = getArtist(metadataList: fetchAssets(playerItem: playerItem))
            songArtwork = getArtwork(metadataList: fetchAssets(playerItem: playerItem))
            songTitle = getTitle(metadataList: fetchAssets(playerItem: playerItem))
        }
    }
    
    func fetchAssets(playerItem: AVPlayerItem) -> [AVMetadataItem] {
        let metadataList = playerItem.asset.metadata
        return metadataList
    }
    
    func getTitle(metadataList: [AVMetadataItem]) -> String? {
        for item in metadataList {
            guard let key = item.commonKey?.rawValue, let value = item.value else { continue }
            
            if key == "title" {
                return value as? String
            }
        }
        return "Error"
    }
    
    func getArtist(metadataList: [AVMetadataItem]) -> String? {
        for item in metadataList {
            guard let key = item.commonKey?.rawValue, let value = item.value else { continue }
            
            if key == "artist" {
                return value as? String
            }
        }
        return "Error"
    }
    
    func getArtwork(metadataList: [AVMetadataItem]) -> Data? {
        for item in metadataList {
            guard let key = item.commonKey?.rawValue, let value = item.value else { continue }
            
            if key == "artwork", value is Data {
                return value as? Data
            }
        }
        
        return nil
    }
    
    func normalizedPowerLevelFromDecibels(decibels: CGFloat) -> CGFloat {
        if decibels < -60.0 || decibels == 0.0 {
            return 0.0
        }
        
        return CGFloat(powf((powf(10.0, 0.05 * Float(decibels)) - powf(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - powf(10.0, 0.05 * -60.0))), 1.0 / 2.0))
    }
}
