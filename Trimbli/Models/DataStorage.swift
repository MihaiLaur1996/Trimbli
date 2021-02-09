//
//  DataStorage.swift
//  Test
//
//  Created by Mihai Laurentiu Mocanu on 18.11.2020.
//

import Firebase
import RealmSwift

class DataStorage {
    
    static let realm = try! Realm()

    static func documentDirectoryReference() -> URL? {
        var documentDirectory: URL?
        
        do {
            documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            print(error)
        }
        
        return documentDirectory
    }
    
    static func songStorage(songID: String) {
        if let documentDirectory = documentDirectoryReference() {
            let localFile = documentDirectory.appendingPathComponent(songID)
            let storageReference = Storage.storage().reference(withPath: songID)
            let download = storageReference.write(toFile: localFile) { (url, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                if url != nil {
                    let downloadedSong = DownloadedSong()
                    downloadedSong.downloadedSongID = songID
                    
                    do {
                        try self.realm.write {
                            self.realm.add(downloadedSong)
                            NotificationCenter.default.post(name: .writeToRealmDatabase, object: nil)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            download.observe(.progress) { (snapshot) in
                guard let progress = snapshot.progress?.fractionCompleted else { return }
                NotificationCenter.default.post(name: .valueHasChanged, object: nil)
                SearchViewController.progress = progress
            }
        }
    }
}
