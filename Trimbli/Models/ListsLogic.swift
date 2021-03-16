//
//  ListsLogic.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 18.02.2021.
//

import UIKit
import Firebase
import AVFoundation

struct ListsLogic {
    
    static let shared = ListsLogic()
    
    //MARK: - Local Selection
    func triggerLocalSelection(TV: UITableViewController) {
        if MediaPlayer.shared.audioSourceConfiguration == .none || MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            clearLocalSelection(TV)
        }
        
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            markLocalSong(TV)
        }
    }
    
    private func clearLocalSelection(_ TV: UITableViewController) {
        if !MediaPlayer.shared.downloadedSongs.isEmpty {
            for i in 0...MediaPlayer.shared.downloadedSongs.count - 1 {
                let cell = TV.tableView.cellForRow(at: IndexPath(row: i, section: 0))
                cell?.textLabel?.textColor = .white
            }
        }
    }
    
    private func markLocalSong(_ TV: UITableViewController) {
        if MediaPlayer.shared.shuffleState == true {
            for i in 0...MediaPlayer.shared.playlistShuffled.count - 1 {
                let cell = TV.tableView.cellForRow(at: IndexPath(row: i, section: 0))
                cell?.textLabel?.textColor = .white
                if MediaPlayer.shared.chosenSong == MediaPlayer.shared.downloadedSongs[i].downloadedSongID {
                    cell?.textLabel?.textColor = UIColor.accentColor
                }
            }
        } else {
            for i in 0...MediaPlayer.shared.downloadedSongs.count - 1 {
                let cell = TV.tableView.cellForRow(at: IndexPath(row: i, section: 0))
                cell?.textLabel?.textColor = .white
                if MediaPlayer.shared.chosenSong == MediaPlayer.shared.downloadedSongs[i].downloadedSongID {
                    cell?.textLabel?.textColor = UIColor.accentColor
                }
            }
        }
    }
    
    func setLocalSongs(cell: UITableViewCell, indexPath: IndexPath) {
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .listColor
        if let path = DataStorage.shared.documentDirectoryReference() {
            let completePath = path.appendingPathComponent(MediaPlayer.shared.downloadedSongs[indexPath.row].downloadedSongID)
            let playerItem = AVPlayerItem(url: completePath)
            let metadataList = MediaPlayer.shared.fetchAssets(playerItem: playerItem)
            do {
                if let songTitle = try MediaPlayer.shared.getTitle(metadataList: metadataList) {
                    cell.textLabel?.text = songTitle
                }
            } catch {
                AlertHandler.shared.showErrorMessage(error.localizedDescription)
            }
        }
    }
    
    //MARK: - Remote Selection
    func triggerRemoteSelection(TV: UITableViewController) {
        if MediaPlayer.shared.audioSourceConfiguration == .none || MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            for i in 0...MediaPlayer.shared.songs.count - 1 {
                let cell = TV.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! RemoteSongCell
                cell.title.textColor = .white
                cell.artist.textColor = .white
            }
        }
        
        if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            markRemoteSong(TV)
        }
    }
    
    private func markRemoteSong(_ TV: UITableViewController) {
        if MediaPlayer.shared.shuffleState == true {
            for i in 0...MediaPlayer.shared.playlistShuffled.count - 1 {
                let cell = TV.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! RemoteSongCell
                cell.title.textColor = .white
                cell.artist.textColor = .white
                if MediaPlayer.shared.chosenSong == MediaPlayer.shared.songs[i].songID {
                    cell.title.textColor = UIColor.accentColor
                    cell.artist.textColor = UIColor.accentColor
                }
            }
        } else {
            for i in 0...MediaPlayer.shared.songs.count - 1 {
                let cell = TV.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! RemoteSongCell
                cell.title.textColor = .white
                cell.artist.textColor = .white
                if MediaPlayer.shared.chosenSong == MediaPlayer.shared.songs[i].songID {
                    cell.title.textColor = UIColor.accentColor
                    cell.artist.textColor = UIColor.accentColor
                }
            }
        }
    }
    
    func setRemoteSongs(cell: RemoteSongCell, indexPath: IndexPath) {
        cell.title.textColor = .white
        cell.artist.textColor = .white
        cell.backgroundColor = UIColor.listColor
        cell.songID.text = MediaPlayer.shared.songs[indexPath.row].songID
        if MediaPlayer.shared.songs[indexPath.row].isDownloaded == true {
            cell.downloadSong.isHidden = true
        }
        
        let storageReference = Storage.storage().reference(withPath: MediaPlayer.shared.songs[indexPath.row].songID)
        storageReference.downloadURL { (url, error) in
            if error != nil {
                let errorMessage = "Failed attempt at retrieving remote data."
                AlertHandler.shared.showErrorMessage(errorMessage)
                return
            }
            
            fetchData(url, cell)
        }
    }
    
    private func fetchData(_ url: URL?, _ cell: RemoteSongCell) {
        if let url = url {
            DispatchQueue.global(qos: .background).async {
                let playerItem = AVPlayerItem(url: url)
                let metadataList = MediaPlayer.shared.fetchAssets(playerItem: playerItem)
                do {
                    let songArtwork = try MediaPlayer.shared.getArtwork(metadataList: metadataList)
                    let songTitle = try MediaPlayer.shared.getTitle(metadataList: metadataList)
                    let songArtist = try MediaPlayer.shared.getArtist(metadataList: metadataList)
                    
                    if let songArtwork = songArtwork, let songTitle = songTitle, let songArtist = songArtist {
                        DispatchQueue.main.async {
                            cell.artwork.image = UIImage(data: songArtwork)
                            cell.title.text = songTitle
                            cell.artist.text = songArtist
                        }
                    }
                } catch {
                    AlertHandler.shared.showErrorMessage(error.localizedDescription)
                }
            }
        }
    }
    
    //MARK: - Song Selection For Playback
    func selectLocalSong(indexPath: IndexPath) {
        if MediaPlayer.shared.audioSourceConfiguration == .none {
            MediaPlayer.shared.audioSourceConfiguration = .some(.localConfiguration)
        }
        
        if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            MediaPlayerLogic.shared.removePeriodicTimeObserver()
            MediaPlayer.shared.remotePlayer = nil
            MediaPlayer.shared.audioSourceConfiguration = .some(.localConfiguration)
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[indexPath.row].downloadedSongID
            if MediaPlayer.shared.shuffleState == true {
                MediaPlayerLogic.shared.createShufflePlaylist()
            } else {
                MediaPlayer.shared.songIndex = indexPath
            }
            MediaPlayer.shared.isPaused = false
            MediaPlayer.shared.playLocal(songID: MediaPlayer.shared.chosenSong)
            NotificationCenter.default.post(name: .selectedRemote, object: nil)
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            if MediaPlayer.shared.chosenSong != MediaPlayer.shared.downloadedSongs[indexPath.row].downloadedSongID {
                songSelection(song: MediaPlayer.shared.downloadedSongs[indexPath.row].downloadedSongID, indexPath: indexPath)
                MediaPlayer.shared.playLocal(songID: MediaPlayer.shared.chosenSong)
                MediaPlayer.shared.isPaused = false
                if MediaPlayer.shared.repeatState == .repeatingOnlyOne {
                    MediaPlayer.shared.repeatState = .repeating
                }
            }
        }
    }
    
    func selectRemoteSong(indexPath: IndexPath) {
        MediaPlayer.shared.progressTimer.invalidate()
        if MediaPlayer.shared.audioSourceConfiguration == .none {
            MediaPlayer.shared.audioSourceConfiguration = .some(.remoteConfiguration)
        }
        
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            MediaPlayer.shared.isPaused = true
            MediaPlayer.shared.audioSourceConfiguration = .some(.remoteConfiguration)
            NotificationCenter.default.post(name: .selectedLocal, object: nil)
            MediaPlayer.shared.localPlayer = nil
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[indexPath.row].songID
            if MediaPlayer.shared.shuffleState == true {
                MediaPlayerLogic.shared.createShufflePlaylist()
            } else {
                MediaPlayer.shared.songIndex = indexPath
            }
            MediaPlayer.shared.playRemote(songID: MediaPlayer.shared.chosenSong)
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            if MediaPlayer.shared.chosenSong != MediaPlayer.shared.songs[indexPath.row].songID {
                songSelection(song: MediaPlayer.shared.songs[indexPath.row].songID, indexPath: indexPath)
                MediaPlayer.shared.playRemote(songID: MediaPlayer.shared.chosenSong)
                if MediaPlayer.shared.repeatState == .repeatingOnlyOne {
                    MediaPlayer.shared.repeatState = .repeating
                }
            }
        }
    }
    
    private func songSelection(song: String, indexPath: IndexPath) {
        if MediaPlayer.shared.shuffleState == false {
            MediaPlayer.shared.songIndex = indexPath
            MediaPlayer.shared.chosenSong = song
        } else {
            MediaPlayer.shared.chosenSong = song
            for i in 0...MediaPlayer.shared.playlistShuffled.count - 1 {
                if MediaPlayer.shared.chosenSong == MediaPlayer.shared.playlistShuffled[i] {
                    MediaPlayer.shared.songIndex.row = i
                }
            }
        }
    }
}
