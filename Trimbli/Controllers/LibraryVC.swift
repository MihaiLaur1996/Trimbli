//
//  LibraryViewController.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 27.11.2020.
//

import UIKit

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
        ListsLogic.shared.triggerLocalSelection(TV: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MediaPlayer.shared.downloadedSongs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.LocalRelated.localSongCell, for: indexPath)
        ListsLogic.shared.setLocalSongs(cell: cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ListsLogic.shared.selectLocalSong(indexPath: indexPath)
        performSegue(withIdentifier: Constants.segueToPreview, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        NotificationCenter.default.post(name: .selectedLocal, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segueToPreview {
            let localVC = segue.destination as! PreviewViewController
            localVC.updateUI()
        }
    }
    
    func loadData() {
        MediaPlayer.shared.downloadedSongs = DataStorage.shared.realm.objects(DownloadedSong.self)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .readyForRefresh, object: nil)
    }
    
    @objc func refresh() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
