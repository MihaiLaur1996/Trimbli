//
//  LibraryViewController.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 27.11.2020.
//

import UIKit
import Firebase
import RealmSwift

class LibraryViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .writeToRealmDatabase, object: nil)
        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(selected), name: .setSelected, object: nil)
        view.backgroundColor = UIColor(named: "BackgroundColor")
    }
    
    @objc func selected() {
        if MediaPlayer.shared.localPlayer?.isPlaying != nil {
            if MediaPlayer.shared.shuffleState == true {
                for i in 0...MediaPlayer.shared.playlistShuffled.count - 1 {
                    if MediaPlayer.shared.chosenSong == MediaPlayer.shared.downloadedSongs[i].downloadedSongID {
                        tableView.cellForRow(at: IndexPath(row: i, section: 0))?.textLabel?.textColor = UIColor(named: "AccentColor")
                    } else {
                        tableView.cellForRow(at: IndexPath(row: i, section: 0))?.textLabel?.textColor = .white
                    }
                }
            } else {
                for i in 0...MediaPlayer.shared.downloadedSongs.count - 1 {
                    if MediaPlayer.shared.chosenSong == MediaPlayer.shared.downloadedSongs[i].downloadedSongID {
                        tableView.cellForRow(at: IndexPath(row: i, section: 0))?.textLabel?.textColor = UIColor(named: "AccentColor")
                    } else {
                        tableView.cellForRow(at: IndexPath(row: i, section: 0))?.textLabel?.textColor = .white
                    }
                }
            }
        }
    }
    
    @objc func refresh() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MediaPlayer.shared.downloadedSongs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.LocalRelated.localSongCell, for: indexPath)
        cell.textLabel?.textColor = .white
        cell.backgroundColor = UIColor(named: "BackgroundColor")
        if let path = DataStorage.documentDirectoryReference() {
            let completePath = path.appendingPathComponent(MediaPlayer.shared.downloadedSongs[indexPath.row].downloadedSongID)
            let metadataList = MediaPlayer.shared.fetchAssets(url: completePath)
            if let songTitle = MediaPlayer.shared.getTitle(metadataList: metadataList) {
                cell.textLabel?.text = songTitle
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if MediaPlayer.shared.shuffleState == false && MediaPlayer.shared.chosenSong != MediaPlayer.shared.downloadedSongs[indexPath.row].downloadedSongID {
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[indexPath.row].downloadedSongID
            MediaPlayer.shared.playLocal(songName: MediaPlayer.shared.chosenSong)
            MediaPlayer.shared.songIndex = indexPath
            MediaPlayer.shared.isPaused = false
            selected()
            if MediaPlayer.shared.repeatState == .repeatingOnlyOne {
                MediaPlayer.shared.repeatState = .repeating
            }
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: Constants.LocalRelated.segueToLocal, sender: self)
        } else if MediaPlayer.shared.shuffleState == true && MediaPlayer.shared.chosenSong != MediaPlayer.shared.downloadedSongs[indexPath.row].downloadedSongID {
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[indexPath.row].downloadedSongID
            MediaPlayer.shared.playLocal(songName: MediaPlayer.shared.chosenSong)
            for i in 0...MediaPlayer.shared.playlistShuffled.count - 1 {
                if MediaPlayer.shared.chosenSong == MediaPlayer.shared.playlistShuffled[i] {
                    MediaPlayer.shared.songIndex.row = i
                }
            }
            MediaPlayer.shared.isPaused = false
            selected()
            if MediaPlayer.shared.repeatState == .repeatingOnlyOne {
                MediaPlayer.shared.repeatState = .repeating
            }
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: Constants.LocalRelated.segueToLocal, sender: self)
        } else if MediaPlayer.shared.localPlayer?.isPlaying == false || MediaPlayer.shared.localPlayer?.isPlaying == true {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: Constants.LocalRelated.segueToLocal, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.LocalRelated.segueToLocal {
            let localVC = segue.destination as! LocalViewController
            localVC.updateUI()
        }
    }
    
    func loadData() {
        MediaPlayer.shared.downloadedSongs = DataStorage.realm.objects(DownloadedSong.self)
        tableView.reloadData()
    }
}
