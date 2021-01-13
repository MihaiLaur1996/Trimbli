//
//  MediaPlayer.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 16/10/2020.
//

import AVFoundation
//import Firebase
import RealmSwift

class MediaPlayer {
    
    static var shared = MediaPlayer()
    static var playing = MediaPlayer.shared.remotePlayer?.timeControlStatus == AVPlayer.TimeControlStatus.playing
    static var paused = MediaPlayer.shared.remotePlayer?.timeControlStatus == AVPlayer.TimeControlStatus.paused
    var songs: [Song] = []
    var downloadedSongs: Results<DownloadedSong>!
    var chosenSong: String = ""
    var songIndex: IndexPath = IndexPath(index: 0)
    var progressValue: Float = 0.0
    var currentTime: String = "0:00"
    var totalTime: String = ""
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
    
    static var duration: Double {
        if let duration = MediaPlayer.shared.remotePlayer?.currentItem?.asset.duration.seconds {
            return duration
        }
        return 0.0
    }
    
//    func playRemote(songName: String) {
//        let storageReference = Storage.storage().reference(withPath: songName)
//        storageReference.downloadURL { (url, error) in
//            if let error = error {
//                print(error)
//                return
//            }
//            
//            DispatchQueue.global(qos: .background).async {
//                if let url = url {
//                    let playerItem = AVPlayerItem.init(url: url)
//                    self.remotePlayer = AVPlayer.init(playerItem: playerItem)
//                    self.remotePlayer?.play()
//
//                    let metadataList = self.fetchAssetsRemote(url: url)
//                    self.songArtwork = self.getArtwork(metadataList: metadataList)
//                    self.songTitle = self.getTitle(metadataList: metadataList)
//                    self.songArtist = self.getArtist(metadataList: metadataList)
//                }
//            }
//        }
//    }
    
    func playLocal(songName: String) {
        if let storedURLAsString = DataStorage.readPathStorage() {
            if let storedURL = URL(string: storedURLAsString) {
                let completeURL = storedURL.appendingPathComponent(songName)
                do {
                    localPlayer = try AVAudioPlayer(contentsOf: completeURL)
                    
                    let storage = DataStorage.documentDirectoryReference()?.appendingPathComponent(songName)
                    if let storage = storage {
                        songArtist = getArtist(metadataList: fetchAssets(url: storage))
                        songArtwork = getArtwork(metadataList: fetchAssets(url: storage))
                        songTitle = getTitle(metadataList: fetchAssets(url: storage))
                    }
                    localPlayer?.isMeteringEnabled = true
                    localPlayer?.play()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func fetchAssets(url: URL) -> [AVMetadataItem] {
        let asset = AVAsset(url: url)
        let metadataList = asset.metadata
        
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
    
    func getTotalDurationRemote() {
        let totalMinutes = (Int(MediaPlayer.shared.remotePlayer?.currentItem?.asset.duration.seconds ?? 0.0) % 3600) / 60
        let totalSeconds = (Int(MediaPlayer.shared.remotePlayer?.currentItem?.asset.duration.seconds ?? 0.0) % 3600) % 60
        if totalSeconds < 10 {
            MediaPlayer.shared.totalTime = "\(totalMinutes):0\(totalSeconds)"
        } else {
            MediaPlayer.shared.totalTime = "\(totalMinutes):\(totalSeconds)"
        }
    }
    
    func getTotalDurationLocal() {
        let totalMinutes = (Int(MediaPlayer.shared.localPlayer?.duration ?? 0.0) % 3600) / 60
        let totalSeconds = (Int(MediaPlayer.shared.localPlayer?.duration ?? 0.0) % 3600) % 60
        if totalSeconds < 10 {
            MediaPlayer.shared.totalTime = "\(totalMinutes):0\(totalSeconds)"
        } else {
            MediaPlayer.shared.totalTime = "\(totalMinutes):\(totalSeconds)"
        }
    }
}
