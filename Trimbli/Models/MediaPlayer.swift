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
    
    static var shared = MediaPlayer()
//    static var playing = MediaPlayer.shared.remotePlayer?.timeControlStatus == AVPlayer.TimeControlStatus.playing
//    static var paused = MediaPlayer.shared.remotePlayer?.timeControlStatus == AVPlayer.TimeControlStatus.paused
    var songs: [Song] = []
    var downloadedSongs: Results<DownloadedSong>!
    var chosenSong: String = ""
    var songIndex: IndexPath = IndexPath(index: 0)
    var progressValue: Float = 0.0
    var currentTime: String = "0:00"
    var totalDuration: String = ""
    var duration: Double = 0.0
    var currentMinutes = 0
    var currentSeconds = 0
    var remotePlayer: AVPlayer?
    var localPlayer: AVAudioPlayer?
    var songArtwork: Data?
    var songTitle: String?
    var songArtist: String?
    var shuffleState: Bool = false
    var repeatState: Replaying = Replaying.notRepeating
    var progressTimer = Timer()
    var isPaused: Bool = false
    var playlistShuffled = [String]()
    
    func playRemote(songName: String) {
        if let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/trimbli-c3d0a.appspot.com/o/\(songName)?alt=media") {
            let playerItem = AVPlayerItem(url: url)
            DispatchQueue.global(qos: .background).async { [self] in
                songArtist = getArtist(metadataList: fetchAssets(playerItem: playerItem))
                songArtwork = getArtwork(metadataList: fetchAssets(playerItem: playerItem))
                songTitle = getTitle(metadataList: fetchAssets(playerItem: playerItem))
            }
            remotePlayer = AVPlayer(playerItem: playerItem)
            remotePlayer?.playImmediately(atRate: 1.0)
        }
    }
    
    func playLocal(songName: String) {
        if let storedURL = DataStorage.documentDirectoryReference() {
                let completeURL = storedURL.appendingPathComponent(songName)
                do {
                    localPlayer = try AVAudioPlayer(contentsOf: completeURL)
                    let storage = DataStorage.documentDirectoryReference()?.appendingPathComponent(songName)
                    if let storage = storage {
                        let playerItem = AVPlayerItem(url: storage)
                        songArtist = getArtist(metadataList: fetchAssets(playerItem: playerItem))
                        songArtwork = getArtwork(metadataList: fetchAssets(playerItem: playerItem))
                        songTitle = getTitle(metadataList: fetchAssets(playerItem: playerItem))
                    }
                    localPlayer?.isMeteringEnabled = true
                    localPlayer?.play()
                } catch {
                    print(error)
                }
            }
    }
    
    func fetchAssets(playerItem: AVPlayerItem) -> [AVMetadataItem] {
        let metadataList = playerItem.asset.metadata
        return metadataList
    }
    
    func getTitle(metadataList: [AVMetadataItem]) -> String? {
        for item in metadataList {
            guard let key = item.commonKey?.rawValue, let value = item.value else {
                continue
            }
            
            if key == "title" {
                return value as? String
            }
        }
        return "Error"
    }
    
    func getArtist(metadataList: [AVMetadataItem]) -> String? {
        for item in metadataList {
            guard let key = item.commonKey?.rawValue, let value = item.value else {
                continue
            }
            
            if key == "artist" {
                return value as? String
            }
        }
        return "Error"
    }
    
    func getArtwork(metadataList: [AVMetadataItem]) -> Data? {
        for item in metadataList {
            guard let key = item.commonKey?.rawValue, let value = item.value else {
                continue
            }
            
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
    
    func getTotalDurationRemote() -> String {
        if MediaPlayer.shared.remotePlayer?.status == .some(.readyToPlay) {
            let minutes = (Int(MediaPlayer.shared.remotePlayer?.currentItem?.asset.duration.seconds ?? 0.0) % 3600) / 60
            let seconds = (Int(MediaPlayer.shared.remotePlayer?.currentItem?.asset.duration.seconds ?? 0.0) % 3600) % 60
            
            if seconds < 10 {
                return "\(minutes):0\(seconds)"
            } else {
                return "\(minutes):\(seconds)"
            }
        }
        return "0:00"
    }
    
    func getTotalDurationLocal() {
        let totalMinutes = (Int(MediaPlayer.shared.localPlayer?.duration ?? 0.0) % 3600) / 60
        let totalSeconds = (Int(MediaPlayer.shared.localPlayer?.duration ?? 0.0) % 3600) % 60
        if totalSeconds < 10 {
            MediaPlayer.shared.totalDuration = "\(totalMinutes):0\(totalSeconds)"
        } else {
            MediaPlayer.shared.totalDuration = "\(totalMinutes):\(totalSeconds)"
        }
    }
    
    func addElements() {
        if MediaPlayer.shared.playlistShuffled.count <= MediaPlayer.shared.downloadedSongs.count {
            for i in 0...MediaPlayer.shared.downloadedSongs.count - 1 {
                let newElement = MediaPlayer.shared.downloadedSongs[i].downloadedSongID
                MediaPlayer.shared.playlistShuffled.append(newElement)
                MediaPlayer.shared.playlistShuffled.removeDuplicates()
            }
        }
    }
}
