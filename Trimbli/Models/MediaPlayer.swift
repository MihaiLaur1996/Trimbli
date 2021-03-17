//
//  MediaPlayer.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 16/10/2020.
//

import AVFoundation
import RealmSwift

class MediaPlayer {
    
    static let shared = MediaPlayer()
    var audioSourceConfiguration: AudioSourceConfiguration?
    var playerItem: AVPlayerItem?
    var remotePlayer: AVPlayer?
    var localPlayer: AVAudioPlayer?
    var songs: [Song] = []
    var downloadedSongs: Results<DownloadedSong>!
    var playlistShuffled = [String]()
    var chosenSong: String = ""
    var songIndex: IndexPath = IndexPath(index: 0)
    var songArtwork: Data?
    var songTitle: String?
    var songArtist: String?
    var currentTime: String = "0:00"
    var progressValue: Float = 0.0
    var totalDuration: String = ""
    var duration: Double = 0.0
    var shuffleState: Bool = false
    var repeatState: Replaying = .notRepeating
    var progressTimer = Timer()
    var isPaused: Bool = false
    var timeObserverToken: Any?
    
    func playRemote(songID: String) {
        if let url = URLLocation.fetchURL(songID) {
            MediaPlayerLogic.shared.removePeriodicTimeObserver()
            playerItem = AVPlayerItem(url: url)
            if let playerItem = playerItem {
                remotePlayer = AVPlayer(playerItem: playerItem)
                DispatchQueue.global(qos: .background).async { [self] in
                    do {
                        songTitle = try getTitle(metadataList: fetchAssets(playerItem: playerItem))
                        songArtist = try getArtist(metadataList: fetchAssets(playerItem: playerItem))
                        songArtwork = try getArtwork(metadataList: fetchAssets(playerItem: playerItem))
                    } catch {
                        AlertHandler.shared.showErrorMessage(error.localizedDescription)
                    }
                }
                remotePlayer?.playImmediately(atRate: 1.0)
                NotificationCenter.default.post(name: .progressObservation, object: nil)
            }
        }
    }
    
    func playLocal(songID: String) {
        if let storedURL = DataStorage.shared.documentDirectoryReference() {
            let completeURL = storedURL.appendingPathComponent(songID)
            do {
                localPlayer = try AVAudioPlayer(contentsOf: completeURL)
                localPlayer?.isMeteringEnabled = true
                localPlayer?.play()
            } catch {
                let errorMessage = "Could not load player. Please try again."
                AlertHandler.shared.showErrorMessage(errorMessage)
            }
        }
    }
    
    func setAssets(songID: String) {
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            if let storedURL = DataStorage.shared.documentDirectoryReference() {
                let completeURL = storedURL.appendingPathComponent(songID)
                playerItem = AVPlayerItem(url: completeURL)
                if let playerItem = playerItem {
                    do {
                        songTitle = try getTitle(metadataList: fetchAssets(playerItem: playerItem))
                        songArtist = try getArtist(metadataList: fetchAssets(playerItem: playerItem))
                        songArtwork = try getArtwork(metadataList: fetchAssets(playerItem: playerItem))
                    } catch {
                        AlertHandler.shared.showErrorMessage(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func fetchAssets(playerItem: AVPlayerItem) -> [AVMetadataItem] {
        return playerItem.asset.metadata
    }
    
    func getTitle(metadataList: [AVMetadataItem]) throws -> String? {
        for item in metadataList {
            guard let key = item.commonKey?.rawValue, let value = item.value else { continue }
            
            if key == "title" {
                return value as? String
            }
        }
        throw "Could not get song title."
    }
    
    func getArtist(metadataList: [AVMetadataItem]) throws -> String? {
        for item in metadataList {
            guard let key = item.commonKey?.rawValue, let value = item.value else { continue }
            
            if key == "artist" {
                return value as? String
            }
        }
        throw "Could not get song artist."
    }
    
    func getArtwork(metadataList: [AVMetadataItem]) throws -> Data? {
        for item in metadataList {
            guard let key = item.commonKey?.rawValue, let value = item.value else { continue }
            
            if key == "artwork", value is Data {
                return value as? Data
            }
        }
        
        throw "Could not get song artwork."
    }
}
