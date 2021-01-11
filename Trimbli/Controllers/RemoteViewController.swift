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
    
    @IBOutlet weak var sliderValue: UISlider!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var songValueProgress: UIProgressView!
    @IBOutlet weak var songTimeProgress: UILabel!
    @IBOutlet weak var songTotalDuration: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var artistLabel: MarqueeLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurEffect()
        NotificationCenter.default.addObserver(self, selector: #selector(playerReadyToPlay), name: .AVPlayerItemNewAccessLogEntry, object: nil)
    }
    
    @objc func playerReadyToPlay() {
        MediaPlayer.playing = true
        updateUI()
    }
    
    @IBAction func backwardPressed(_ sender: UIButton) {
        if MediaPlayer.shared.songIndex.row == 0 {
            return
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(playerReadyToPlay), name: .AVPlayerItemNewAccessLogEntry, object: nil)
            MediaPlayer.shared.songIndex.row -= 1
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
//            MediaPlayer.shared.playRemote(songName: MediaPlayer.chosenSong)
        }
        NotificationCenter.default.post(name: .setSelected, object: nil)
    }
    
    @IBAction func playPausePressed(_ sender: UIButton) {
        songValueProgress.progress = MediaPlayer.shared.progressValue
        if MediaPlayer.paused == false {
            MediaPlayer.shared.remotePlayer?.pause()
            playPauseButton.setImage(UIImage(named: "play_button"), for: .normal)
            MediaPlayer.paused = !MediaPlayer.paused
        } else {
            MediaPlayer.shared.remotePlayer?.play()
            playPauseButton.setImage(UIImage(named: "pause_button"), for: .normal)
            MediaPlayer.paused = !MediaPlayer.paused
        }
    }
    
    @IBAction func forwardPressed(_ sender: UIButton) {
        if MediaPlayer.shared.songIndex.row == MediaPlayer.shared.songs.count - 1 {
            return
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(playerReadyToPlay), name: .AVPlayerItemNewAccessLogEntry, object: nil)
            MediaPlayer.shared.songIndex.row += 1
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.songs[MediaPlayer.shared.songIndex.row].songID
//            MediaPlayer.shared.playRemote(songName: MediaPlayer.chosenSong)
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        print(sliderValue.value)
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            if let songArtwork = MediaPlayer.shared.songArtwork, let songTitle = MediaPlayer.shared.songTitle, let songArtist = MediaPlayer.shared.songArtist {
                self.artistImage.image = UIImage(data: songArtwork)
                self.backgroundImage.image = UIImage(data: songArtwork)
                self.titleLabel.text = songTitle
                self.artistLabel.text = songArtist
                self.songValueProgress.progress = MediaPlayer.shared.progressValue
                if MediaPlayer.shared.currentSeconds < 10 {
                    self.songTimeProgress.text = "\(MediaPlayer.shared.currentMinutes):0\(MediaPlayer.shared.currentSeconds)"
                } else {
                    self.songTimeProgress.text = "\(MediaPlayer.shared.currentMinutes):\(MediaPlayer.shared.currentSeconds)"
                }
                self.timerObserver()
                self.songTotalDuration.text = MediaPlayer.shared.totalTime
                if MediaPlayer.paused == true {
                    self.playPauseButton.setImage(UIImage(named: "play_button"), for: .normal)
                } else if MediaPlayer.paused == false {
                    self.playPauseButton.setImage(UIImage(named: "pause_button"), for: .normal)
                }
            }
        }
    }
    
    func timerObserver() {
        let interval = CMTime(value: 1, timescale: 2)
        MediaPlayer.shared.remotePlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { (progressTime) in
            let time = CMTimeGetSeconds(progressTime)
            MediaPlayer.shared.currentMinutes = Int(time) / 60
            MediaPlayer.shared.currentSeconds = Int(time) % 60
            if MediaPlayer.shared.currentSeconds < 10 {
                self.songTimeProgress.text = "\(MediaPlayer.shared.currentMinutes):0\(MediaPlayer.shared.currentSeconds)"
            } else {
                self.songTimeProgress.text = "\(MediaPlayer.shared.currentMinutes):\(MediaPlayer.shared.currentSeconds)"
            }
            
            MediaPlayer.shared.progressValue = Float(time) / Float(MediaPlayer.duration)
            self.songValueProgress.progress = MediaPlayer.shared.progressValue
        })
    }
    
    func blurEffect() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.backgroundImage.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImage.addSubview(blurEffectView)
    }
}
