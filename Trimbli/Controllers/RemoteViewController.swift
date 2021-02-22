//
//  RemoteViewController.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 06/10/2020.
//

import UIKit
import AVFoundation
import MarqueeLabel

class RemoteViewController: UIViewController {
    
    @IBOutlet weak var artistLabel: MarqueeLabel!
    @IBOutlet weak var artworkImage: UIImageView!
    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var songTimeProgress: UILabel!
    @IBOutlet weak var totalDuration: UILabel!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var songRepeat: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MediaPlayer.shared.progressTimer.invalidate()
        if MediaPlayer.shared.remotePlayer?.timeControlStatus != .some(.paused) {
            MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
        }
        backgroundImage.blurImage()
        NotificationCenter.default.addObserver(self, selector: #selector(playerReadyToPlay), name: .AVPlayerItemNewAccessLogEntry, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ended), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.post(name: .selectedRemote, object: nil)
    }
    
    @objc func ended() {
        progressThroughSongs()
    }
    
    @objc func playerReadyToPlay() {
        if let duration = MediaPlayer.shared.remotePlayer?.currentItem?.duration.seconds {
            MediaPlayer.shared.duration = duration
        }
        
        MediaPlayerLogic.shared.getTotalDuration()
        playPauseButton.setImage(UIImage.pause, for: .normal)
        updateUI()
    }
    
    @IBAction func shufflePressed(_ sender: UIButton) {
        if MediaPlayer.shared.shuffleState == true {
            MediaPlayer.shared.shuffleState = false
        } else {
            MediaPlayer.shared.shuffleState = true
        }
        MediaPlayerLogic.shared.createShufflePlaylist()
        updateUI()
    }
    
    @IBAction func backwardPressed(_ sender: UIButton) {
        MediaPlayerLogic.shared.playBackwardSong()
        if MediaPlayer.shared.songIndex.row == MediaPlayer.shared.downloadedSongs.count - 1 {
            MediaPlayer.shared.progressTimer.invalidate()
            MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerReadyToPlay), name: .AVPlayerItemNewAccessLogEntry, object: nil)
        NotificationCenter.default.post(name: .selectedRemote, object: nil)
    }
    
    @IBAction func playPausePressed(_ sender: UIButton) {
        if MediaPlayer.shared.remotePlayer?.timeControlStatus != .some(.paused) {
            MediaPlayer.shared.remotePlayer?.pause()
            MediaPlayer.shared.progressTimer.invalidate()
        } else {
            MediaPlayer.shared.remotePlayer?.play()
            MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
        }
        MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: MediaPlayerLogic.self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
        updateUI()
    }
    
    @IBAction func forwardPressed(_ sender: UIButton) {
        MediaPlayer.shared.progressTimer.invalidate()
        MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
        if MediaPlayer.shared.shuffleState == false {
            if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.songs.count - 1 {
                MediaPlayer.shared.songIndex.row = 0
            } else {
                MediaPlayer.shared.songIndex.row += 1
            }
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
            DispatchQueue.global(qos: .background).async {
                MediaPlayer.shared.playRemote(songName: MediaPlayer.shared.chosenSong)
            }
        } else {
            if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.playlistShuffled.count - 1 {
                MediaPlayer.shared.songIndex.row = 0
            } else {
                MediaPlayer.shared.songIndex.row += 1
            }
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.playlistShuffled[MediaPlayer.shared.songIndex.row]
            DispatchQueue.global(qos: .background).async {
                MediaPlayer.shared.playRemote(songName: MediaPlayer.shared.chosenSong)
            }
        }
        
        if MediaPlayer.shared.repeatState == .repeatingOnlyOne {
            MediaPlayer.shared.repeatState = .repeating
        }
        
        NotificationCenter.default.post(name: .AVPlayerItemNewAccessLogEntry, object: nil)
    }
    
    @IBAction func repeatSong(_ sender: UIButton) {
        MediaPlayerLogic.shared.changeRepeatingState()
        updateUI()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        MediaPlayer.shared.progressTimer.invalidate()
        MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
        MediaPlayer.shared.progressValue = sender.value
        DispatchQueue.global(qos: .background).async {
            MediaPlayer.shared.remotePlayer?.seek(to: CMTime(value: CMTimeValue(MediaPlayer.shared.progressValue), timescale: 1))
        }
        DispatchQueue.main.async { [weak self] in
            self?.progressSlider.setValue(MediaPlayer.shared.progressValue, animated: true)
        }
        updateUI()
    }
    
    func updateUI() {
        DispatchQueue.main.async { [weak self] in
            if let songArtwork = MediaPlayer.shared.songArtwork, let songTitle = MediaPlayer.shared.songTitle, let songArtist = MediaPlayer.shared.songArtist {
                self?.artworkImage.image = UIImage(data: songArtwork)
                self?.backgroundImage.image = UIImage(data: songArtwork)
                self?.titleLabel.text = songTitle
                self?.artistLabel.text = songArtist
            }
            switch MediaPlayer.shared.repeatState {
            case .notRepeating:
                self?.songRepeat.setImage(UIImage.replayIsNotRepeating, for: .normal)
            case .repeating:
                self?.songRepeat.setImage(UIImage.replayIsRepeating, for: .normal)
            case .repeatingOnlyOne:
                self?.songRepeat.setImage(UIImage.replayIsRepeatingOnlyOne, for: .normal)
            }
            if MediaPlayer.shared.shuffleState == true {
                self?.shuffleButton.setImage(UIImage.shuffleIsActive, for: .normal)
            } else if MediaPlayer.shared.shuffleState == false {
                self?.shuffleButton.setImage(UIImage.shuffleIsNotActive, for: .normal)
            }
            self?.progressSlider.setThumbImage(UIImage.circleFillSmall, for: .normal)
            self?.progressSlider.setThumbImage(UIImage.circleFillMedium, for: .highlighted)
            self?.progressSlider.minimumValue = 0.0
            self?.progressSlider.maximumValue = Float(MediaPlayer.shared.duration)
            MediaPlayerLogic.shared.getCurrentSeconds()
            self?.progressSlider.value = MediaPlayer.shared.progressValue
            self?.totalDuration.text = MediaPlayer.shared.totalDuration
            if MediaPlayer.shared.remotePlayer?.timeControlStatus == .some(.paused) {
                self?.playPauseButton.setImage(UIImage.play, for: .normal)
            } else if MediaPlayer.shared.remotePlayer?.timeControlStatus != .paused {
                self?.playPauseButton.setImage(UIImage.pause, for: .normal)
            }
        }
    }
    
    func progressThroughSongs() {
        switch MediaPlayer.shared.repeatState {
        case .notRepeating:
            if MediaPlayer.shared.shuffleState == false {
                if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.songs.count - 1 {
                    MediaPlayer.shared.songIndex.row = 0
                    MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
                    DispatchQueue.global(qos: .background).async {
                        MediaPlayer.shared.playRemote(songName: MediaPlayer.shared.chosenSong)
                        MediaPlayer.shared.remotePlayer?.pause()
                    }
                } else {
                    MediaPlayer.shared.songIndex.row += 1
                    MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
                    DispatchQueue.global(qos: .background).async {
                        MediaPlayer.shared.playRemote(songName: MediaPlayer.shared.chosenSong)
                    }
                }
            } else {
                if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.playlistShuffled.count - 1 {
                    MediaPlayer.shared.songIndex.row = 0
                    MediaPlayer.shared.chosenSong = MediaPlayer.shared.playlistShuffled[MediaPlayer.shared.songIndex.row]
                    DispatchQueue.global(qos: .background).async {
                        MediaPlayer.shared.playRemote(songName: MediaPlayer.shared.chosenSong)
                        MediaPlayer.shared.remotePlayer?.pause()
                    }
                } else {
                    MediaPlayer.shared.songIndex.row += 1
                    MediaPlayer.shared.chosenSong = MediaPlayer.shared.playlistShuffled[MediaPlayer.shared.songIndex.row]
                    DispatchQueue.global(qos: .background).async {
                        MediaPlayer.shared.playRemote(songName: MediaPlayer.shared.chosenSong)
                    }
                }
            }
        case .repeating:
            if MediaPlayer.shared.shuffleState == false {
                if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.songs.count - 1 {
                    MediaPlayer.shared.songIndex.row = 0
                } else {
                    MediaPlayer.shared.songIndex.row += 1
                }
                MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
            } else {
                if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.playlistShuffled.count - 1 {
                    MediaPlayer.shared.songIndex.row = 0
                } else {
                    MediaPlayer.shared.songIndex.row += 1
                }
                MediaPlayer.shared.chosenSong = MediaPlayer.shared.playlistShuffled[MediaPlayer.shared.songIndex.row]
            }
            
            DispatchQueue.global(qos: .background).async {
                MediaPlayer.shared.playRemote(songName: MediaPlayer.shared.chosenSong)
            }
        case .repeatingOnlyOne:
            DispatchQueue.global(qos: .background).async {
                MediaPlayer.shared.playRemote(songName: MediaPlayer.shared.chosenSong)
            }
        }
        updateUI()
    }
    
    @objc func updateAudioProgressView() {
//        MediaPlayer.shared.score += 1
//        print(MediaPlayer.shared.score)
//        
        if MediaPlayer.shared.remotePlayer?.timeControlStatus == .some(.playing) {
            if progressSlider.isHighlighted == false {
                MediaPlayer.shared.progressValue = Float(MediaPlayer.shared.remotePlayer?.currentItem?.currentTime().seconds ?? 0.0)
                DispatchQueue.main.async { [weak self] in
                    self?.progressSlider.setValue(MediaPlayer.shared.progressValue, animated: false)
                }
            }
            MediaPlayerLogic.shared.getCurrentSeconds()
        } else if MediaPlayer.shared.progressValue != 0.0 {
            DispatchQueue.global(qos: .background).async {
                MediaPlayer.shared.progressValue = Float(MediaPlayer.shared.remotePlayer?.currentItem?.currentTime().seconds ?? 0.0)
                DispatchQueue.main.async { [weak self] in
                    self?.progressSlider.setValue(MediaPlayer.shared.progressValue, animated: false)
                }
            }
        }
        
        NotificationCenter.default.post(name: .selectedRemote, object: nil)
    }
}
