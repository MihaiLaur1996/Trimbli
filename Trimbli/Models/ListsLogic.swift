//
//  ListsLogic.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 18.02.2021.
//

import UIKit
import AVFoundation

struct ListsLogic {
    static let shared = ListsLogic()
    
    func setSelectedLocal(TV: UITableViewController) {
        if MediaPlayer.shared.localPlayer == nil {
            for i in 0...MediaPlayer.shared.downloadedSongs.count - 1 {
                let cell = TV.tableView.cellForRow(at: IndexPath(row: i, section: 0))
                cell?.textLabel?.textColor = .white
            }
        }
        
        if MediaPlayer.shared.localPlayer != nil {
            if MediaPlayer.shared.shuffleState == true {
                for i in 0...MediaPlayer.shared.playlistShuffled.count - 1 {
                    let cell = TV.tableView.cellForRow(at: IndexPath(row: i, section: 0))
                    if MediaPlayer.shared.chosenSong == MediaPlayer.shared.downloadedSongs[i].downloadedSongID {
                        cell?.textLabel?.textColor = UIColor.accentColor
                    } else {
                        cell?.textLabel?.textColor = .white
                    }
                }
            } else {
                for i in 0...MediaPlayer.shared.downloadedSongs.count - 1 {
                    let cell = TV.tableView.cellForRow(at: IndexPath(row: i, section: 0))
                    if MediaPlayer.shared.chosenSong == MediaPlayer.shared.downloadedSongs[i].downloadedSongID {
                        cell?.textLabel?.textColor = UIColor.accentColor
                    } else {
                        cell?.textLabel?.textColor = .white
                    }
                }
            }
        }
    }
    
    func setSongs(cell: UITableViewCell, indexPath: IndexPath) {
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .listColor
        if let path = DataStorage.documentDirectoryReference() {
            let completePath = path.appendingPathComponent(MediaPlayer.shared.downloadedSongs[indexPath.row].downloadedSongID)
            let playerItem = AVPlayerItem(url: completePath)
            let metadataList = MediaPlayer.shared.fetchAssets(playerItem: playerItem)
            if let songTitle = MediaPlayer.shared.getTitle(metadataList: metadataList) {
                cell.textLabel?.text = songTitle
            }
        }
    }
    
    func selectSong(indexPath: IndexPath) {
        if MediaPlayer.shared.audioSourceConfiguration == .none {
            MediaPlayer.shared.audioSourceConfiguration = .some(.localConfiguration)
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            MediaPlayer.shared.remotePlayer = nil
            NotificationCenter.default.post(name: .selectedRemote, object: nil)
            MediaPlayer.shared.audioSourceConfiguration = .some(.localConfiguration)
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[indexPath.row].downloadedSongID
            MediaPlayerLogic.shared.createShufflePlaylist()
            MediaPlayer.shared.isPaused = false
            MediaPlayer.shared.playLocal(songName: MediaPlayer.shared.chosenSong)
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            if MediaPlayer.shared.chosenSong != MediaPlayer.shared.downloadedSongs[indexPath.row].downloadedSongID {
                if MediaPlayer.shared.shuffleState == false {
                    MediaPlayer.shared.songIndex = indexPath
                    MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[MediaPlayer.shared.songIndex.row].downloadedSongID
                    MediaPlayer.shared.playLocal(songName: MediaPlayer.shared.chosenSong)
                } else {
                    MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[indexPath.row].downloadedSongID
                    MediaPlayer.shared.playLocal(songName: MediaPlayer.shared.chosenSong)
                    for i in 0...MediaPlayer.shared.playlistShuffled.count - 1 {
                        if MediaPlayer.shared.chosenSong == MediaPlayer.shared.playlistShuffled[i] {
                            MediaPlayer.shared.songIndex.row = i
                        }
                    }
                }
                MediaPlayer.shared.isPaused = false
                if MediaPlayer.shared.repeatState == .repeatingOnlyOne {
                    MediaPlayer.shared.repeatState = .repeating
                }
            }
        }
    }
}
