//
//  SearchViewController.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 04/10/2020.
//

import UIKit
import Firebase

class SearchViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = UIColor.listColor
        tableView.register(UINib(nibName: Constants.RemoteRelated.remoteSongCell, bundle: nil), forCellReuseIdentifier: Constants.RemoteRelated.remoteSongCell)
        DataStorage.shared.fetchSongData()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .readyForRefresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selected), name: .selectedRemote, object: nil)
    }
    
    @objc func selected() {
        ListsLogic.shared.triggerRemoteSelection(TV: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MediaPlayer.shared.songs.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = view.backgroundColor
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.RemoteRelated.remoteSongCell, for: indexPath) as! RemoteSongCell
        ListsLogic.shared.setRemoteSongs(cell: cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ListsLogic.shared.selectRemoteSong(indexPath: indexPath)
        DispatchQueue.main.async { [self] in
            tableView.deselectRow(at: indexPath, animated: false)
            performSegue(withIdentifier: Constants.segueToPreview, sender: self)
            NotificationCenter.default.post(name: .selectedRemote, object: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segueToPreview {
            let previewVC = segue.destination as! PreviewViewController
            previewVC.updateUI()
        }
    }
    
    @objc func refresh() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            AlertHandler.shared.alertController.dismiss(animated: true, completion: nil)
        }
    }
}
