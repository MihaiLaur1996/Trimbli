//
//  MediaPlayerLogic.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 17.02.2021.
//

import UIKit

struct MediaPlayerLogic {
    
    static let shared = MediaPlayerLogic()
    
    func getCurrentSeconds() {
        var minutes = 0
        var seconds = 0
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            minutes = (Int(MediaPlayer.shared.localPlayer?.currentTime ?? 0.0) % 3600) / 60
            seconds = (Int(MediaPlayer.shared.localPlayer?.currentTime ?? 0.0) % 3600) % 60
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            minutes = (Int(MediaPlayer.shared.playerItem?.currentTime().seconds ?? 0.0) % 3600) / 60
            seconds = (Int(MediaPlayer.shared.playerItem?.currentTime().seconds ?? 0.0) % 3600) % 60
        }
        if seconds < 10 {
            MediaPlayer.shared.currentTime = "\(minutes):0\(seconds)"
        } else {
            MediaPlayer.shared.currentTime = "\(minutes):\(seconds)"
        }
    }
    
    func getTotalDuration() {
        if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            let minutes = (Int(MediaPlayer.shared.playerItem?.asset.duration.seconds.rounded() ?? 0.0) % 3600) / 60
            let seconds = (Int(MediaPlayer.shared.playerItem?.asset.duration.seconds.rounded() ?? 0.0) % 3600) % 60
            
            if seconds < 10 {
                MediaPlayer.shared.totalDuration = "\(minutes):0\(seconds)"
            } else {
                MediaPlayer.shared.totalDuration = "\(minutes):\(seconds)"
            }
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            let minutes = (Int(MediaPlayer.shared.localPlayer?.duration.rounded() ?? 0.0) % 3600) / 60
            let seconds = (Int(MediaPlayer.shared.localPlayer?.duration.rounded() ?? 0.0) % 3600) % 60
            if seconds < 10 {
                MediaPlayer.shared.totalDuration = "\(minutes):0\(seconds)"
            } else {
                MediaPlayer.shared.totalDuration = "\(minutes):\(seconds)"
            }
        }
    }
    
    func addElement() {
        if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            if MediaPlayer.shared.playlistShuffled.count <= MediaPlayer.shared.songs.count {
                for i in 0...MediaPlayer.shared.songs.count - 1 {
                    let newElement = MediaPlayer.shared.songs[i].songID
                    MediaPlayer.shared.playlistShuffled.append(newElement)
                }
            }
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            if MediaPlayer.shared.playlistShuffled.count <= MediaPlayer.shared.downloadedSongs.count {
                for i in 0...MediaPlayer.shared.downloadedSongs.count - 1 {
                    let newElement = MediaPlayer.shared.downloadedSongs[i].downloadedSongID
                    MediaPlayer.shared.playlistShuffled.append(newElement)
                }
            }
        }
        MediaPlayer.shared.playlistShuffled.removeDuplicates()
    }
    
    func createShufflePlaylist() {
        if MediaPlayer.shared.shuffleState == true {
            MediaPlayer.shared.playlistShuffled = []
            MediaPlayer.shared.playlistShuffled.append(MediaPlayer.shared.chosenSong)
            MediaPlayerLogic.shared.addElement()
            MediaPlayer.shared.songIndex.row = 0
        } else if MediaPlayer.shared.shuffleState == false {
            deselectionFromShuffle()
            MediaPlayer.shared.playlistShuffled = []
        }
    }
    
    private func deselectionFromShuffle() {
        if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            for i in 0...MediaPlayer.shared.songs.count - 1 {
                if MediaPlayer.shared.chosenSong == MediaPlayer.shared.songs[i].songID {
                    MediaPlayer.shared.songIndex.row = i
                }
            }
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            for i in 0...MediaPlayer.shared.downloadedSongs.count - 1 {
                if MediaPlayer.shared.chosenSong == MediaPlayer.shared.downloadedSongs[i].downloadedSongID {
                    MediaPlayer.shared.songIndex.row = i
                }
            }
        }
    }
    
    func changeRepeatingState() {
        switch MediaPlayer.shared.repeatState {
        case .notRepeating:
            MediaPlayer.shared.repeatState = .repeating
        case .repeating:
            MediaPlayer.shared.repeatState = .repeatingOnlyOne
        case .repeatingOnlyOne:
            MediaPlayer.shared.repeatState = .notRepeating
        }
    }
    
    func playPreviousSong() {
        if MediaPlayer.shared.shuffleState == true {
            if MediaPlayer.shared.songIndex.row <= 0 {
                MediaPlayer.shared.songIndex.row = MediaPlayer.shared.playlistShuffled.count - 1
            } else {
                MediaPlayer.shared.songIndex.row -= 1
            }
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.playlistShuffled[MediaPlayer.shared.songIndex.row]
        } else {
            previousSongSelectionFromPlaylist()
        }
        
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            MediaPlayer.shared.playLocal(songID: MediaPlayer.shared.chosenSong)
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            MediaPlayer.shared.playRemote(songID: MediaPlayer.shared.chosenSong)
        }
        
        if MediaPlayer.shared.repeatState == .repeatingOnlyOne {
            MediaPlayer.shared.repeatState = .repeating
        }
    }
    
    private func previousSongSelectionFromPlaylist() {
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            if MediaPlayer.shared.songIndex.row <= 0 {
                MediaPlayer.shared.songIndex.row = MediaPlayer.shared.downloadedSongs.count - 1
            } else {
                MediaPlayer.shared.songIndex.row -= 1
            }
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[MediaPlayer.shared.songIndex.row].downloadedSongID
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            if MediaPlayer.shared.songIndex.row == 0 {
                MediaPlayer.shared.songIndex.row = MediaPlayer.shared.songs.count - 1
            } else {
                MediaPlayer.shared.songIndex.row -= 1
            }
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
        }
    }
    
    func playNextSong() {
        if MediaPlayer.shared.shuffleState == true {
            if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.playlistShuffled.count - 1 {
                MediaPlayer.shared.songIndex.row = 0
            } else {
                MediaPlayer.shared.songIndex.row += 1
            }
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.playlistShuffled[MediaPlayer.shared.songIndex.row]
            if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
                MediaPlayer.shared.playLocal(songID: MediaPlayer.shared.chosenSong)
            } else if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
                MediaPlayer.shared.playRemote(songID: MediaPlayer.shared.chosenSong)
            }
        } else {
            nextSongSelectionFromPlaylist()
        }
        
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            MediaPlayer.shared.playLocal(songID: MediaPlayer.shared.chosenSong)
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            MediaPlayer.shared.playRemote(songID: MediaPlayer.shared.chosenSong)
        }
        
        if MediaPlayer.shared.repeatState == .repeatingOnlyOne {
            MediaPlayer.shared.repeatState = .repeating
        }
    }
    
    private func nextSongSelectionFromPlaylist() {
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.downloadedSongs.count - 1 {
                MediaPlayer.shared.songIndex.row = 0
            } else {
                MediaPlayer.shared.songIndex.row += 1
            }
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[MediaPlayer.shared.songIndex.row].downloadedSongID
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.songs.count - 1 {
                MediaPlayer.shared.songIndex.row = 0
            } else {
                MediaPlayer.shared.songIndex.row += 1
            }
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
        }
    }
    
    func playPause() {
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            if MediaPlayer.shared.localPlayer?.isPlaying == true {
                MediaPlayer.shared.progressTimer.invalidate()
                MediaPlayer.shared.localPlayer?.pause()
                MediaPlayer.shared.isPaused = true
            } else {
                MediaPlayer.shared.localPlayer?.play()
                MediaPlayer.shared.isPaused = false
            }
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            MediaPlayerLogic.shared.removePeriodicTimeObserver()
            if MediaPlayer.shared.remotePlayer?.timeControlStatus == .some(.paused) {
                MediaPlayer.shared.remotePlayer?.play()
                NotificationCenter.default.post(name: .progressObservation, object: nil)
            } else {
                MediaPlayer.shared.remotePlayer?.pause()
            }
        }
    }
    
    func progressThroughSongsLocal() {
        if MediaPlayer.shared.shuffleState == true {
            if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.playlistShuffled.count - 1 {
                MediaPlayer.shared.songIndex.row = 0
            } else {
                MediaPlayer.shared.songIndex.row += 1
            }
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.playlistShuffled[MediaPlayer.shared.songIndex.row]
        } else {
            progressing()
        }
        
        MediaPlayer.shared.playLocal(songID: MediaPlayer.shared.chosenSong)
        if MediaPlayer.shared.repeatState == .repeatingOnlyOne {
            MediaPlayer.shared.repeatState = .repeating
        }
    }
    
    private func progressing() {
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.downloadedSongs.count - 1 {
                MediaPlayer.shared.songIndex.row = 0
            } else {
                MediaPlayer.shared.songIndex.row += 1
            }
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[MediaPlayer.shared.songIndex.row].downloadedSongID
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.songs.count - 1 {
                MediaPlayer.shared.songIndex.row = 0
            } else {
                MediaPlayer.shared.songIndex.row += 1
            }
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
        }
    }
    
    func progressThroughSongsRemote() {
        switch MediaPlayer.shared.repeatState {
        case .notRepeating: notRepeatingProgress()
        case .repeating: repeatingProgress()
        case .repeatingOnlyOne: DispatchQueue.global(qos: .background).async { MediaPlayer.shared.playRemote(songID: MediaPlayer.shared.chosenSong) }
        }
        NotificationCenter.default.post(name: .selectedRemote, object: nil)
    }
    
    private func notRepeatingProgress() {
        if MediaPlayer.shared.shuffleState == false {
            if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.songs.count - 1 {
                MediaPlayer.shared.songIndex.row = 0
                MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
                DispatchQueue.global(qos: .background).async {
                    MediaPlayer.shared.playRemote(songID: MediaPlayer.shared.chosenSong)
                    MediaPlayer.shared.remotePlayer?.pause()
                }
            } else {
                MediaPlayer.shared.songIndex.row += 1
                MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
                DispatchQueue.global(qos: .background).async {
                    MediaPlayer.shared.playRemote(songID: MediaPlayer.shared.chosenSong)
                }
            }
        } else {
            if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.playlistShuffled.count - 1 {
                MediaPlayer.shared.songIndex.row = 0
                MediaPlayer.shared.chosenSong = MediaPlayer.shared.playlistShuffled[MediaPlayer.shared.songIndex.row]
                DispatchQueue.global(qos: .background).async {
                    MediaPlayer.shared.playRemote(songID: MediaPlayer.shared.chosenSong)
                    MediaPlayer.shared.remotePlayer?.pause()
                }
            } else {
                MediaPlayer.shared.songIndex.row += 1
                MediaPlayer.shared.chosenSong = MediaPlayer.shared.playlistShuffled[MediaPlayer.shared.songIndex.row]
                DispatchQueue.global(qos: .background).async {
                    MediaPlayer.shared.playRemote(songID: MediaPlayer.shared.chosenSong)
                }
            }
        }
    }
    
    private func repeatingProgress() {
        if MediaPlayer.shared.shuffleState == false {
            if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.songs.count - 1 {
                MediaPlayer.shared.songIndex.row = 0
            } else {
                MediaPlayer.shared.songIndex.row += 1
            }
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
        } else {
            if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.playlistShuffled.count - 1 {
                MediaPlayer.shared.songIndex.row = 0
            } else {
                MediaPlayer.shared.songIndex.row += 1
            }
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.playlistShuffled[MediaPlayer.shared.songIndex.row]
        }
        
        DispatchQueue.global(qos: .background).async {
            MediaPlayer.shared.playRemote(songID: MediaPlayer.shared.chosenSong)
        }
    }
    
    func notRepeatingAutoProgress() {
        if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.downloadedSongs.count - 1 {
            if MediaPlayer.shared.shuffleState == false {
                MediaPlayer.shared.songIndex.row = 0
                MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[MediaPlayer.shared.songIndex.row].downloadedSongID
            } else {
                MediaPlayer.shared.songIndex.row = 0
                MediaPlayer.shared.chosenSong = MediaPlayer.shared.playlistShuffled[MediaPlayer.shared.songIndex.row]
            }
            MediaPlayer.shared.playLocal(songID: MediaPlayer.shared.chosenSong)
            MediaPlayerLogic.shared.getTotalDuration()
            MediaPlayer.shared.localPlayer?.pause()
            MediaPlayer.shared.isPaused = true
            MediaPlayer.shared.progressTimer.invalidate()
        } else {
            MediaPlayerLogic.shared.progressThroughSongsLocal()
        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = MediaPlayer.shared.timeObserverToken {
            MediaPlayer.shared.remotePlayer?.removeTimeObserver(timeObserverToken)
            MediaPlayer.shared.timeObserverToken = nil
        }
    }
    
    func normalizedPowerLevelFromDecibels(decibels: CGFloat) -> CGFloat {
        if decibels < -60.0 || decibels == 0.0 {
            return 0.0
        }
        
        return CGFloat(powf((powf(10.0, 0.05 * Float(decibels)) - powf(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - powf(10.0, 0.05 * -60.0))), 1.0 / 2.0))
    }
}
