//
//  SearchViewController.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 04/10/2020.
//

import UIKit
import Firebase
import AVFoundation

class SearchViewController: UITableViewController {
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    static let database = Firestore.firestore()
    static var progress = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        progressBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .valueHasChanged, object: nil)
        tableView.register(UINib(nibName: Constants.RemoteRelated.remoteSongCell, bundle: nil), forCellReuseIdentifier: Constants.RemoteRelated.remoteSongCell)
        fetchSongData()
        view.backgroundColor = UIColor.listColor
        NotificationCenter.default.addObserver(self, selector: #selector(selected), name: .selectedRemote, object: nil)
    }
    
    @objc func selected() {
        if MediaPlayer.shared.remotePlayer == nil {
            for i in 0...MediaPlayer.shared.songs.count - 1 {
                let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! RemoteSongCell
                cell.title.textColor = .white
                cell.artist.textColor = .white
            }
        }

        if MediaPlayer.shared.remotePlayer != nil {
            if MediaPlayer.shared.shuffleState == true {
                for i in 0...MediaPlayer.shared.playlistShuffled.count - 1 {
                    let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! RemoteSongCell
                    if MediaPlayer.shared.chosenSong == MediaPlayer.shared.songs[i].songID {
                        cell.title.textColor = UIColor.accentColor
                        cell.artist.textColor = UIColor.accentColor
                    } else {
                        cell.title.textColor = .white
                        cell.artist.textColor = .white
                    }
                }
            } else {
                for i in 0...MediaPlayer.shared.songs.count - 1 {
                    let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! RemoteSongCell
                    if MediaPlayer.shared.chosenSong == MediaPlayer.shared.songs[i].songID {
                        cell.title.textColor = UIColor.accentColor
                        cell.artist.textColor = UIColor.accentColor
                    } else {
                        cell.title.textColor = .white
                        cell.artist.textColor = .white
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MediaPlayer.shared.songs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.RemoteRelated.remoteSongCell, for: indexPath) as! RemoteSongCell
        cell.title.textColor = .white
        cell.artist.textColor = .white
        cell.backgroundColor = UIColor.listColor
        cell.songID.text = MediaPlayer.shared.songs[indexPath.row].songID
        if MediaPlayer.shared.songs[indexPath.row].isDownloaded == true {
            cell.downloadSong.isHidden = true
        }

        let storageReference = Storage.storage().reference(withPath: MediaPlayer.shared.songs[indexPath.row].songID)
        storageReference.downloadURL { (url, error) in
            if let error = error {
                print(error)
                return
            }

            if let url = url {
                DispatchQueue.global(qos: .background).async {
                    let playerItem = AVPlayerItem(url: url)
                    let metadataList = MediaPlayer.shared.fetchAssets(playerItem: playerItem)
                    let songArtwork = MediaPlayer.shared.getArtwork(metadataList: metadataList)
                    let songTitle = MediaPlayer.shared.getTitle(metadataList: metadataList)
                    let songArtist = MediaPlayer.shared.getArtist(metadataList: metadataList)

                    if let songArtwork = songArtwork, let songTitle = songTitle, let songArtist = songArtist {
                        DispatchQueue.main.async {
                            cell.artwork.image = UIImage(data: songArtwork)
                            cell.title.text = songTitle
                            cell.artist.text = songArtist
                        }
                    }
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if MediaPlayer.shared.audioSourceConfiguration == .none || MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            MediaPlayer.shared.audioSourceConfiguration = .some(.remoteConfiguration)
        }
        if MediaPlayer.shared.localPlayer != nil {
            MediaPlayer.shared.localPlayer = nil
            NotificationCenter.default.post(name: .selectedLocal, object: nil)
            MediaPlayer.shared.chosenSong = ""
            MediaPlayer.shared.songIndex = IndexPath(index: 0)
        }
        if MediaPlayer.shared.shuffleState == false && MediaPlayer.shared.chosenSong != MediaPlayer.shared.songs[indexPath.row].songID {
            MediaPlayer.shared.songIndex = indexPath
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
            MediaPlayer.shared.playRemote(songName: MediaPlayer.shared.chosenSong)
            if MediaPlayer.shared.repeatState == .repeatingOnlyOne {
                MediaPlayer.shared.repeatState = .repeating
            }
            readyForSegue(indexPath: indexPath)
        } else {
            readyForSegue(indexPath: indexPath)
        }
    }
    
    func fetchSongData() {
        DispatchQueue.global(qos: .background).async {
            SearchViewController.database.collection(Constants.collectionName).order(by: Constants.FirebaseSongAttributes.songID, descending: false).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for document in snapshotDocuments {
                            let data = document.data()
                            if let songID = data[Constants.FirebaseSongAttributes.songID] as? String, let isDownloaded = data[Constants.FirebaseSongAttributes.isDownloaded] as? Bool {
                                let song = Song(songID: songID, isDownloaded: isDownloaded)
                                MediaPlayer.shared.songs.append(song)

                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func refresh() {
        progressBar.progress = Float(SearchViewController.progress)
        progressBar.isHidden = false
        if SearchViewController.progress >= 0.99 {
            progressBar.isHidden = true
        }
    }
    
    static func updateStatus(documentTitle: String, documentID: String) {
        database.collection(Constants.collectionName).document(documentID).setData([Constants.FirebaseSongAttributes.isDownloaded: true, Constants.FirebaseSongAttributes.songID: documentID])
    }
    
    func readyForSegue(indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: Constants.RemoteRelated.segueToRemote, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.RemoteRelated.segueToRemote {
            let previewVC = segue.destination as! RemoteViewController
            previewVC.updateUI()
        }
    }
}
