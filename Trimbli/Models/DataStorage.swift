//
//  DataStorage.swift
//  Test
//
//  Created by Mihai Laurentiu Mocanu on 18.11.2020.
//

import Firebase
import RealmSwift

class DataStorage {
    
    static let shared = DataStorage()
    let realm = try! Realm()
    let database = Firestore.firestore()
    var progress = 0.0
    
    func documentDirectoryReference() -> URL? {
        var documentDirectory: URL?
        
        do {
            documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            print(error)
        }
        
        return documentDirectory
    }
    
    func songStorage(songID: String) {
        if let documentDirectory = documentDirectoryReference() {
            let localFile = documentDirectory.appendingPathComponent(songID)
            let storageReference = Storage.storage().reference(withPath: songID)
            let download = storageReference.write(toFile: localFile) { (url, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.downloadTask(url, songID)
            }
            download.observe(.progress) { (snapshot) in
                guard let progress = snapshot.progress?.fractionCompleted else { return }
                NotificationCenter.default.post(name: .valueHasChanged, object: nil)
                DataStorage.shared.progress = progress
                print(DataStorage.shared.progress)
            }
        }
    }
    
    func downloadTask(_ url: URL?, _ songID: String) {
        if url != nil {
            let downloadedSong = DownloadedSong()
            downloadedSong.downloadedSongID = songID
            
            do {
                try self.realm.write {
                    self.realm.add(downloadedSong)
                    NotificationCenter.default.post(name: .readyForRefresh, object: nil)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func updateStatus(documentTitle: String, documentID: String) {
        DataStorage.shared.database.collection(Constants.collectionName).document(documentID).setData([Constants.FirebaseSongAttributes.isDownloaded: true, Constants.FirebaseSongAttributes.songID: documentID])
    }
    
    func fetchSongData() {
        DispatchQueue.global(qos: .background).async {
            DataStorage.shared.database.collection(Constants.collectionName).order(by: Constants.FirebaseSongAttributes.songID, descending: false).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                } else {
                    DataStorage.shared.getSnapshots(querySnapshot)
                }
            }
        }
    }
    
    private func getSnapshots(_ querySnapshot: QuerySnapshot?) {
        if let snapshotDocuments = querySnapshot?.documents {
            for document in snapshotDocuments {
                let data = document.data()
                if let songID = data[Constants.FirebaseSongAttributes.songID] as? String, let isDownloaded = data[Constants.FirebaseSongAttributes.isDownloaded] as? Bool {
                    let song = Song(songID: songID, isDownloaded: isDownloaded)
                    MediaPlayer.shared.songs.append(song)
                    NotificationCenter.default.post(name: .readyForRefresh, object: nil)
                }
            }
        }
    }
}
