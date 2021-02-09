//
//  RemoteSongCell.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 23.11.2020.
//

import UIKit
//import Firebase

class RemoteSongCell: UITableViewCell {

    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var downloadSong: UIButton!
    
    let songID = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        songID.isHidden = true
        downloadSong.setImage(UIImage(systemName: "arrow.down", withConfiguration: UIImage.largeConfiguration), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        if let songID = songID.text {
            for i in 0...MediaPlayer.shared.songs.count - 1 {
                if songID == MediaPlayer.shared.songs[i].songID {
                    downloadSong.isHidden = true
                    DataStorage.songStorage(songID: MediaPlayer.shared.songs[i].songID)
                    SearchViewController.updateStatus(documentTitle: MediaPlayer.shared.songs[i].songID, documentID: MediaPlayer.shared.songs[i].songID)
                }
            }
        }
    }
}
