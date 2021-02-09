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
    @IBOutlet weak var playPauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MediaPlayer.shared.progressTimer.invalidate()
        backgroundImage.blurImage()
        NotificationCenter.default.addObserver(self, selector: #selector(playerReadyToPlay), name: .AVPlayerItemNewAccessLogEntry, object: MediaPlayer.shared.remotePlayer?.currentItem)
        MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
    }
    
    @objc func playerReadyToPlay() {
        if let duration = MediaPlayer.shared.remotePlayer?.currentItem?.duration.seconds {
            MediaPlayer.shared.duration = duration
        }
        
        MediaPlayer.shared.totalDuration = MediaPlayer.shared.getTotalDurationRemote()
        totalDuration.text = MediaPlayer.shared.totalDuration
        playPauseButton.setImage(UIImage.pause, for: .normal)
        updateUI()
    }
    
    @IBAction func backwardPressed(_ sender: UIButton) {
        MediaPlayer.shared.progressTimer.invalidate()
        if MediaPlayer.shared.songIndex.row == 0 {
            MediaPlayer.shared.songIndex.row = MediaPlayer.shared.songs.count - 1
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
            MediaPlayer.shared.playRemote(songName: MediaPlayer.shared.chosenSong)
        } else {
            MediaPlayer.shared.songIndex.row -= 1
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
            MediaPlayer.shared.playRemote(songName: MediaPlayer.shared.chosenSong)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerReadyToPlay), name: .AVPlayerItemNewAccessLogEntry, object: MediaPlayer.shared.remotePlayer?.currentItem)
    }
    
    @IBAction func playPausePressed(_ sender: UIButton) {
        if MediaPlayer.shared.remotePlayer?.timeControlStatus != .some(.paused) {
            MediaPlayer.shared.remotePlayer?.pause()
            MediaPlayer.shared.progressTimer.invalidate()
        } else {
            MediaPlayer.shared.remotePlayer?.play()
            MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
        }
        
        updateUI()
    }
    
    @IBAction func forwardPressed(_ sender: UIButton) {
        MediaPlayer.shared.progressTimer.invalidate()
        if MediaPlayer.shared.songIndex.row == MediaPlayer.shared.songs.count - 1 {
            MediaPlayer.shared.songIndex.row = 0
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
            MediaPlayer.shared.playRemote(songName: MediaPlayer.shared.chosenSong)
        } else {
            MediaPlayer.shared.songIndex.row += 1
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
            MediaPlayer.shared.playRemote(songName: MediaPlayer.shared.chosenSong)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerReadyToPlay), name: .AVPlayerItemNewAccessLogEntry, object: MediaPlayer.shared.remotePlayer?.currentItem)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        MediaPlayer.shared.progressTimer.invalidate()
        MediaPlayer.shared.remotePlayer?.seek(to: CMTime(value: CMTimeValue(sender.value), timescale: 1))
        progressSlider.setValue(sender.value, animated: true)
        MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
        updateUI()
    }
    
    func updateUI() {
        DispatchQueue.main.async { [self] in
            if let songArtwork = MediaPlayer.shared.songArtwork, let songTitle = MediaPlayer.shared.songTitle, let songArtist = MediaPlayer.shared.songArtist {
                artworkImage.image = UIImage(data: songArtwork)
                backgroundImage.image = UIImage(data: songArtwork)
                titleLabel.text = songTitle
                artistLabel.text = songArtist
            }
            progressSlider.value = MediaPlayer.shared.progressValue
            progressSlider.setThumbImage(UIImage.circleFillSmall, for: .normal)
            progressSlider.setThumbImage(UIImage.circleFillMedium, for: .highlighted)
            progressSlider.minimumValue = 0.0
            progressSlider.maximumValue = Float(MediaPlayer.shared.duration)
            if MediaPlayer.shared.currentSeconds < 10 {
                songTimeProgress.text = "\(MediaPlayer.shared.currentMinutes):0\(MediaPlayer.shared.currentSeconds)"
            } else {
                songTimeProgress.text = "\(MediaPlayer.shared.currentMinutes):\(MediaPlayer.shared.currentSeconds)"
            }
            if MediaPlayer.shared.remotePlayer?.timeControlStatus == .some(.paused) {
                playPauseButton.setImage(UIImage.play, for: .normal)
            } else if MediaPlayer.shared.remotePlayer?.timeControlStatus != .some(.paused) {
                playPauseButton.setImage(UIImage.pause, for: .normal)
            }
        }
    }
    
    @objc func updateAudioProgressView() {
//        if MediaPlayer.playing == true {
            if progressSlider.isHighlighted == false {
                MediaPlayer.shared.progressValue = Float(MediaPlayer.shared.remotePlayer?.currentTime().seconds ?? 0.0)
                progressSlider.setValue(MediaPlayer.shared.progressValue, animated: false)
            }
            getCurrentSeconds()
        print(MediaPlayer.shared.remotePlayer?.timeControlStatus == .some(.paused))
//        } else if MediaPlayer.shared.progressValue != 0.0 {
//            MediaPlayer.shared.progressValue = Float(MediaPlayer.shared.remotePlayer?.currentTime().seconds ?? 0.0)
//            progressSlider.setValue(MediaPlayer.shared.progressValue, animated: false)
//        }
//        print(MediaPlayer.paused)
    }
    
    func getCurrentSeconds() {
        let minutes = (Int(MediaPlayer.shared.remotePlayer?.currentTime().seconds ?? 0.0) % 3600) / 60
        let seconds = (Int(MediaPlayer.shared.remotePlayer?.currentTime().seconds ?? 0.0) % 3600) % 60
        if seconds < 10 {
            MediaPlayer.shared.currentTime = "\(minutes):0\(seconds)"
            songTimeProgress.text = MediaPlayer.shared.currentTime
        } else {
            MediaPlayer.shared.currentTime = "\(minutes):\(seconds)"
            songTimeProgress.text = MediaPlayer.shared.currentTime
        }
    }
}
