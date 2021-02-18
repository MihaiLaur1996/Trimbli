//
//  MediaPlayerLogic.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 17.02.2021.
//

import UIKit

class MediaPlayerLogic {
    
    static let shared = MediaPlayerLogic()
    
    func getTotalDuration() {
        if MediaPlayer.shared.remotePlayer?.timeControlStatus == .some(.playing) {
            if MediaPlayer.shared.remotePlayer?.status == .some(.readyToPlay) {
                let minutes = (Int(MediaPlayer.shared.remotePlayer?.currentItem?.asset.duration.seconds ?? 0.0) % 3600) / 60
                let seconds = (Int(MediaPlayer.shared.remotePlayer?.currentItem?.asset.duration.seconds ?? 0.0) % 3600) % 60
                
                if seconds < 10 {
                    MediaPlayer.shared.totalDuration = "\(minutes):0\(seconds)"
                } else {
                    MediaPlayer.shared.totalDuration = "\(minutes):\(seconds)"
                }
            }
        } else if MediaPlayer.shared.localPlayer?.isPlaying == true {
            let minutes = (Int(MediaPlayer.shared.localPlayer?.duration ?? 0.0) % 3600) / 60
            let seconds = (Int(MediaPlayer.shared.localPlayer?.duration ?? 0.0) % 3600) % 60
            if seconds < 10 {
                MediaPlayer.shared.totalDuration = "\(minutes):0\(seconds)"
            } else {
                MediaPlayer.shared.totalDuration = "\(minutes):\(seconds)"
            }
        }
    }
    
    func addElement() {
        if MediaPlayer.shared.remotePlayer != nil {
            if MediaPlayer.shared.playlistShuffled.count <= MediaPlayer.shared.songs.count {
                for i in 0...MediaPlayer.shared.songs.count - 1 {
                    let newElement = MediaPlayer.shared.songs[i].songID
                    MediaPlayer.shared.playlistShuffled.append(newElement)
                    MediaPlayer.shared.playlistShuffled.removeDuplicates()
                }
            }
        } else if MediaPlayer.shared.localPlayer != nil {
            if MediaPlayer.shared.playlistShuffled.count <= MediaPlayer.shared.downloadedSongs.count {
                for i in 0...MediaPlayer.shared.downloadedSongs.count - 1 {
                    let newElement = MediaPlayer.shared.downloadedSongs[i].downloadedSongID
                    MediaPlayer.shared.playlistShuffled.append(newElement)
                    MediaPlayer.shared.playlistShuffled.removeDuplicates()
                }
            }
        }
    }
    
    func createShufflePlayList() {
        if MediaPlayer.shared.shuffleState == false {
            MediaPlayer.shared.shuffleState = true
            MediaPlayer.shared.playlistShuffled = []
            MediaPlayer.shared.playlistShuffled.append(MediaPlayer.shared.chosenSong)
            MediaPlayerLogic.shared.addElement()
            MediaPlayer.shared.songIndex.row = 0
        } else if MediaPlayer.shared.shuffleState == true {
            MediaPlayer.shared.shuffleState = false
            if MediaPlayer.shared.remotePlayer != nil {
                for i in 0...MediaPlayer.shared.songs.count - 1 {
                    if MediaPlayer.shared.chosenSong == MediaPlayer.shared.songs[i].songID {
                        MediaPlayer.shared.songIndex.row = i
                    }
                }
            } else if MediaPlayer.shared.localPlayer != nil {
                for i in 0...MediaPlayer.shared.downloadedSongs.count - 1 {
                    if MediaPlayer.shared.chosenSong == MediaPlayer.shared.downloadedSongs[i].downloadedSongID {
                        MediaPlayer.shared.songIndex.row = i
                    }
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
    
    func getCurrentSeconds() {
        if MediaPlayer.shared.remotePlayer != nil {
            let minutes = (Int(MediaPlayer.shared.remotePlayer?.currentTime().seconds ?? 0.0) % 3600) / 60
            let seconds = (Int(MediaPlayer.shared.remotePlayer?.currentTime().seconds ?? 0.0) % 3600) % 60
            if seconds < 10 {
                MediaPlayer.shared.currentTime = "\(minutes):0\(seconds)"
            } else {
                MediaPlayer.shared.currentTime = "\(minutes):\(seconds)"
            }
        } else if MediaPlayer.shared.localPlayer != nil {
            let minutes = (Int(MediaPlayer.shared.localPlayer?.currentTime ?? 0.0) % 3600) / 60
            let seconds = (Int(MediaPlayer.shared.localPlayer?.currentTime ?? 0.0) % 3600) % 60
            if seconds < 10 {
                MediaPlayer.shared.currentTime = "\(minutes):0\(seconds)"
            } else {
                MediaPlayer.shared.currentTime = "\(minutes):\(seconds)"
            }
        }
    }
    
    func playBackwardSong() {
        MediaPlayer.shared.progressTimer.invalidate()
        if MediaPlayer.shared.shuffleState == true {
            if MediaPlayer.shared.songIndex.row <= 0 {
                MediaPlayer.shared.songIndex.row = MediaPlayer.shared.playlistShuffled.count - 1
            } else {
                MediaPlayer.shared.songIndex.row -= 1
            }
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.playlistShuffled[MediaPlayer.shared.songIndex.row]
            MediaPlayer.shared.playLocal(songName: MediaPlayer.shared.chosenSong)
        } else {
            if MediaPlayer.shared.localPlayer != nil {
                if MediaPlayer.shared.songIndex.row <= 0 {
                    MediaPlayer.shared.songIndex.row = MediaPlayer.shared.downloadedSongs.count - 1
                } else {
                    MediaPlayer.shared.songIndex.row -= 1
                }
                MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[MediaPlayer.shared.songIndex.row].downloadedSongID
                MediaPlayer.shared.playLocal(songName: MediaPlayer.shared.chosenSong)
            } else if MediaPlayer.shared.remotePlayer != nil {
                if MediaPlayer.shared.songIndex.row == 0 {
                    MediaPlayer.shared.songIndex.row = MediaPlayer.shared.songs.count - 1
                } else {
                    MediaPlayer.shared.songIndex.row -= 1
                }
                MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
                MediaPlayer.shared.playRemote(songName: MediaPlayer.shared.chosenSong)
            }
        }
        if MediaPlayer.shared.repeatState == .repeatingOnlyOne {
            MediaPlayer.shared.repeatState = .repeating
        }
    }
    
    func playPause() {
        if MediaPlayer.shared.localPlayer != nil {
            if MediaPlayer.shared.localPlayer?.isPlaying == true {
                MediaPlayer.shared.progressTimer.invalidate()
                MediaPlayer.shared.localPlayer?.pause()
                MediaPlayer.shared.isPaused = true
            } else {
                MediaPlayer.shared.localPlayer?.play()
                MediaPlayer.shared.isPaused = false
            }
        }
    }
    
    func progressThroughSongs() {
        if MediaPlayer.shared.shuffleState == true {
            if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.playlistShuffled.count - 1 {
                MediaPlayer.shared.songIndex.row = 0
            } else {
                MediaPlayer.shared.songIndex.row += 1
            }
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.playlistShuffled[MediaPlayer.shared.songIndex.row]
            MediaPlayer.shared.playLocal(songName: MediaPlayer.shared.chosenSong)
        } else {
            if MediaPlayer.shared.localPlayer != nil {
                if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.downloadedSongs.count - 1 {
                    MediaPlayer.shared.songIndex.row = 0
                } else {
                    MediaPlayer.shared.songIndex.row += 1
                }
                MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[MediaPlayer.shared.songIndex.row].downloadedSongID
                MediaPlayer.shared.playLocal(songName: MediaPlayer.shared.chosenSong)
            } else if MediaPlayer.shared.remotePlayer != nil {
                if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.songs.count - 1 {
                    MediaPlayer.shared.songIndex.row = 0
                } else {
                    MediaPlayer.shared.songIndex.row += 1
                }
                
                MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
                MediaPlayer.shared.playRemote(songName: MediaPlayer.shared.chosenSong)
            }
        }
        if MediaPlayer.shared.repeatState == .repeatingOnlyOne {
            MediaPlayer.shared.repeatState = .repeating
        }
    }
    
    func automatedProgress() {
        if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.downloadedSongs.count - 1 {
            if MediaPlayer.shared.shuffleState == false {
                MediaPlayer.shared.songIndex.row = 0
                MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[MediaPlayer.shared.songIndex.row].downloadedSongID
            } else {
                MediaPlayer.shared.songIndex.row = 0
                MediaPlayer.shared.chosenSong = MediaPlayer.shared.playlistShuffled[MediaPlayer.shared.songIndex.row]
            }
            MediaPlayer.shared.playLocal(songName: MediaPlayer.shared.chosenSong)
            MediaPlayerLogic.shared.getTotalDuration()
            MediaPlayer.shared.localPlayer?.pause()
            MediaPlayer.shared.isPaused = true
            MediaPlayer.shared.progressTimer.invalidate()
        } else {
            MediaPlayerLogic.shared.progressThroughSongs()
        }
    }
}
