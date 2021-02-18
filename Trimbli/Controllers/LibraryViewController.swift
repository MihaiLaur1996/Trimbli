//
//  LibraryViewController.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 27.11.2020.
//

import UIKit
import Firebase
import RealmSwift
import AVFoundation

class LibraryViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(setSelected), name: .selectedLocal, object: nil)
        view.backgroundColor = .listColor
    }
    
    @objc func setSelected() {
        ListsLogic.shared.setSelectedLocal(TV: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MediaPlayer.shared.downloadedSongs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.LocalRelated.localSongCell, for: indexPath)
        ListsLogic.shared.setSongs(cell: cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ListsLogic.shared.selectSong(indexPath: indexPath)
        performSegue(withIdentifier: Constants.LocalRelated.segueToLocal, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        NotificationCenter.default.post(name: .selectedLocal, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.LocalRelated.segueToLocal {
            let localVC = segue.destination as! LocalViewController
            localVC.updateUI()
        }
    }
    
    func loadData() {
        MediaPlayer.shared.downloadedSongs = DataStorage.realm.objects(DownloadedSong.self)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .writeToRealmDatabase, object: nil)
    }
    
    @objc func refresh() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
