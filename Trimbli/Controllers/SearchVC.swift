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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        progressBar.isHidden = true
        view.backgroundColor = UIColor.listColor
        tableView.register(UINib(nibName: Constants.RemoteRelated.remoteSongCell, bundle: nil), forCellReuseIdentifier: Constants.RemoteRelated.remoteSongCell)
        DataStorage.shared.fetchSongData()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .readyForRefresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selected), name: .selectedRemote, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadProgress), name: .valueHasChanged, object: nil)
    }
    
    @objc func selected() {
        ListsLogic.shared.triggerRemoteSelection(TV: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MediaPlayer.shared.songs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.RemoteRelated.remoteSongCell, for: indexPath) as! RemoteSongCell
        ListsLogic.shared.setRemoteSongs(cell: cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ListsLogic.shared.selectRemoteSong(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: Constants.segueToPreview, sender: self)
        NotificationCenter.default.post(name: .selectedRemote, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segueToPreview {
            let previewVC = segue.destination as! PreviewViewController
            previewVC.updateUI()
        }
    }
    
    @objc func downloadProgress() {
        progressBar.progress = Float(DataStorage.shared.progress)
        progressBar.isHidden = false
        if DataStorage.shared.progress >= 0.99 {
            progressBar.isHidden = true
        }
    }
    
    @objc func refresh() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
