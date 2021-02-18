//
//  LocalViewController.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 27.11.2020.
//

import UIKit
import MarqueeLabel

class LocalViewController: UIViewController {
    
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
    @IBOutlet weak var waveformView: WaveformView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImage.blurImage()
        if MediaPlayer.shared.isPaused != true {
            MediaPlayer.shared.progressTimer.invalidate()
            MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
        }
        let displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(updateMeters))
        displayLink.add(to: .current, forMode: .common)
    }
    
    @IBAction func songProgressChanged(_ sender: UISlider) {
        MediaPlayer.shared.localPlayer?.currentTime = TimeInterval(sender.value)
        updateUI()
    }
    
    @IBAction func shufflePressed(_ sender: UIButton) {
        MediaPlayerLogic.shared.createShufflePlayList()
        updateUI()
    }
    
    @IBAction func backwardButton(_ sender: UIButton) {
        MediaPlayerLogic.shared.playBackwardSong()
        MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
        updateUI()
        NotificationCenter.default.post(name: .selectedLocal, object: nil)
    }
    
    @IBAction func playPauseButton(_ sender: UIButton) {
        MediaPlayerLogic.shared.playPause()
        
        if MediaPlayer.shared.isPaused == false {
            MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
        }
        updateUI()
    }
    
    @IBAction func forwardButton(_ sender: UIButton) {
        MediaPlayer.shared.progressTimer.invalidate()
        MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
        MediaPlayerLogic.shared.progressThroughSongs()
        updateUI()
    }
    
    @IBAction func repeatSong(_ sender: UIButton) {
        MediaPlayerLogic.shared.changeRepeatingState()
        updateUI()
    }
    
    @objc func updateAudioProgressView() {
        if MediaPlayer.shared.localPlayer?.isPlaying == true {
            if progressSlider.isHighlighted == false {
                MediaPlayer.shared.progressValue = Float(MediaPlayer.shared.localPlayer?.currentTime ?? 0.0)
                progressSlider.setValue(MediaPlayer.shared.progressValue, animated: false)
            }
            MediaPlayerLogic.shared.getCurrentSeconds()
        } else if MediaPlayer.shared.progressValue != 0.0 {
            MediaPlayer.shared.progressValue = Float(MediaPlayer.shared.localPlayer?.currentTime ?? 0.0)
            progressSlider.setValue(MediaPlayer.shared.progressValue, animated: false)
        }
        
        if MediaPlayer.shared.localPlayer?.isPlaying == false && MediaPlayer.shared.repeatState == .notRepeating {
            MediaPlayerLogic.shared.automatedProgress()
            updateUI()
        } else if MediaPlayer.shared.localPlayer?.isPlaying == false && MediaPlayer.shared.repeatState == .repeating {
            MediaPlayerLogic.shared.progressThroughSongs()
            updateUI()
        } else if MediaPlayer.shared.localPlayer?.isPlaying == false && MediaPlayer.shared.repeatState == .repeatingOnlyOne {
            MediaPlayer.shared.localPlayer?.play()
        }
        
        songTimeProgress.text = MediaPlayer.shared.currentTime
        NotificationCenter.default.post(name: .selectedLocal, object: nil)
    }
    
    func updateUI() {
        DispatchQueue.main.async { [weak self] in
            self?.waveformView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
            switch MediaPlayer.shared.repeatState {
            case .notRepeating:
                self?.songRepeat.setImage(UIImage.replayIsNotRepeating, for: .normal)
            case .repeating:
                self?.songRepeat.setImage(UIImage.replayIsRepeating, for: .normal)
            case .repeatingOnlyOne:
                self?.songRepeat.setImage(UIImage.replayIsRepeatingOnlyOne, for: .normal)
            }
            MediaPlayer.shared.shuffleState == true ? self?.shuffleButton.setImage(UIImage.shuffleIsActive, for: .normal) : self?.shuffleButton.setImage(UIImage.shuffleIsNotActive, for: .normal)
            MediaPlayer.shared.localPlayer?.isPlaying == true ? self?.playPauseButton.setImage(UIImage.pause, for: .normal) : self?.playPauseButton.setImage(UIImage.play, for: .normal)
            self?.progressSlider.setThumbImage(UIImage.circleFillSmall, for: .normal)
            self?.progressSlider.setThumbImage(UIImage.circleFillMedium, for: .highlighted)
            MediaPlayerLogic.shared.getCurrentSeconds()
            self?.progressSlider.minimumValue = 0.0
            self?.progressSlider.maximumValue = Float(MediaPlayer.shared.localPlayer?.duration ?? 0.0)
            self?.songTimeProgress.text = MediaPlayer.shared.currentTime
            self?.progressSlider.setValue(Float(MediaPlayer.shared.localPlayer?.currentTime ?? 0.0), animated: false)
            MediaPlayerLogic.shared.getTotalDuration()
            self?.totalDuration.text = MediaPlayer.shared.totalDuration
            MediaPlayer.shared.setAssetsLocal(songID: MediaPlayer.shared.chosenSong)
            if let songArtist = MediaPlayer.shared.songArtist, let songArtwork = MediaPlayer.shared.songArtwork, let songTitle = MediaPlayer.shared.songTitle {
                self?.artistLabel.text = songArtist
                self?.artworkImage.image = UIImage(data: songArtwork)
                self?.titleLabel.text = songTitle
                self?.backgroundImage.image = UIImage(data: songArtwork)
            }
        }
    }
    
    @objc func updateMeters() {
        if let averagePower = MediaPlayer.shared.localPlayer?.averagePower(forChannel: 0) {
            let normalizedValue: CGFloat = MediaPlayer.shared.normalizedPowerLevelFromDecibels(decibels: CGFloat(averagePower))
            MediaPlayer.shared.localPlayer?.updateMeters()
            waveformView.updateWithLevel(normalizedValue)
        }
    }
}
