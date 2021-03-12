//
//  PreviewViewController.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 27.11.2020.
//

import UIKit
import AVFoundation
import MarqueeLabel

class PreviewViewController: UIViewController {
    
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
    let waveformView = WaveformView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImage.blurImage()
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            if MediaPlayer.shared.isPaused != true {
                MediaPlayer.shared.progressTimer.invalidate()
                MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
                NotificationCenter.default.addObserver(self, selector: #selector(update), name: .updateUI, object: nil)
            }
            let displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(updateMeters))
            displayLink.add(to: .current, forMode: .common)
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            NotificationCenter.default.addObserver(self, selector: #selector(playerReadyToPlay), name: .AVPlayerItemNewAccessLogEntry, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(progressObservation), name: .progressObservation, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(ended), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            MediaPlayerLogic.shared.removePeriodicTimeObserver()
            PreviewLogic.addPeriodicTimeObserver(progressSlider, songTimeProgress)
        }
    }
    
    @objc func playerReadyToPlay() {
        PreviewLogic.playerReadyForPlayback(playPauseButton: playPauseButton)
        updateUI()
    }
    
    @objc func progressObservation() {
        PreviewLogic.addPeriodicTimeObserver(progressSlider, songTimeProgress)
    }
    
    @objc func ended() {
        if MediaPlayer.shared.remotePlayer?.status == .some(.readyToPlay) {
            MediaPlayerLogic.shared.progressThroughSongsRemote()
            updateUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        PreviewLogic.viewWillAppearCall(view: view, waveformView: waveformView, playPauseButton: playPauseButton)
    }
    
    @IBAction func songProgressChanged(_ sender: UISlider) {
        MediaPlayer.shared.progressValue = sender.value
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            MediaPlayer.shared.localPlayer?.currentTime = TimeInterval(MediaPlayer.shared.progressValue)
            MediaPlayer.shared.progressTimer.invalidate()
            MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            MediaPlayer.shared.remotePlayer?.seek(to: CMTime(value: CMTimeValue(MediaPlayer.shared.progressValue), timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
        }
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
    
    @IBAction func backwardButton(_ sender: UIButton) {
        MediaPlayerLogic.shared.playPreviousSong()
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            MediaPlayer.shared.progressTimer.invalidate()
            MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
            updateUI()
            NotificationCenter.default.post(name: .selectedLocal, object: nil)
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            NotificationCenter.default.addObserver(self, selector: #selector(playerReadyToPlay), name: .AVPlayerItemNewAccessLogEntry, object: nil)
            NotificationCenter.default.post(name: .selectedRemote, object: nil)
        }
    }
    
    @IBAction func playPauseButton(_ sender: UIButton) {
        MediaPlayerLogic.shared.playPause()
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            if MediaPlayer.shared.isPaused == false {
                MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
            }
        }
        updateUI()
    }
    
    @IBAction func forwardButton(_ sender: UIButton) {
        MediaPlayerLogic.shared.playNextSong()
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            MediaPlayer.shared.progressTimer.invalidate()
            MediaPlayer.shared.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
            updateUI()
            NotificationCenter.default.post(name: .selectedLocal, object: nil)
        } else if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
            NotificationCenter.default.addObserver(self, selector: #selector(playerReadyToPlay), name: .AVPlayerItemNewAccessLogEntry, object: nil)
            NotificationCenter.default.post(name: .selectedRemote, object: nil)
        }
    }
    
    @IBAction func repeatSong(_ sender: UIButton) {
        MediaPlayerLogic.shared.changeRepeatingState()
        updateUI()
    }
    
    @objc func updateAudioProgressView() {
        PreviewLogic.triggerLocalTimer(progressSlider: progressSlider, songTimeProgress: songTimeProgress)
    }
    
    @objc func update() {
        updateUI()
    }
    
    func updateUI() {
        DispatchQueue.main.async { [self] in
            MediaPlayer.shared.shuffleState == true ? shuffleButton.setImage(UIImage.shuffleIsActive, for: .normal) : shuffleButton.setImage(UIImage.shuffleIsNotActive, for: .normal)
            progressSlider.setThumbImage(UIImage.circleFillSmall, for: .normal)
            progressSlider.setThumbImage(UIImage.circleFillMedium, for: .highlighted)
            progressSlider.minimumValue = 0.0
            switch MediaPlayer.shared.repeatState {
            case .notRepeating: songRepeat.setImage(UIImage.replayIsNotRepeating, for: .normal)
            case .repeating: songRepeat.setImage(UIImage.replayIsRepeating, for: .normal)
            case .repeatingOnlyOne: songRepeat.setImage(UIImage.replayIsRepeatingOnlyOne, for: .normal)
            }
            if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
                MediaPlayer.shared.setAssetsLocal(songID: MediaPlayer.shared.chosenSong)
                MediaPlayer.shared.localPlayer?.isPlaying == true ? playPauseButton.setImage(UIImage.pause, for: .normal) : playPauseButton.setImage(UIImage.play, for: .normal)
                progressSlider.maximumValue = Float(MediaPlayer.shared.localPlayer?.duration ?? 0.0)
            } else if MediaPlayer.shared.audioSourceConfiguration == .some(.remoteConfiguration) {
                MediaPlayer.shared.remotePlayer?.timeControlStatus == .some(.paused) ? playPauseButton.setImage(UIImage.play, for: .normal) : playPauseButton.setImage(UIImage.pause, for: .normal)
                progressSlider.maximumValue = Float(MediaPlayer.shared.duration)
            }
            MediaPlayerLogic.shared.getCurrentSeconds()
            MediaPlayerLogic.shared.getTotalDuration()
            progressSlider.setValue(MediaPlayer.shared.progressValue, animated: false)
            songTimeProgress.text = MediaPlayer.shared.currentTime
            totalDuration.text = MediaPlayer.shared.totalDuration
            if let songArtist = MediaPlayer.shared.songArtist, let songArtwork = MediaPlayer.shared.songArtwork, let songTitle = MediaPlayer.shared.songTitle {
                artistLabel.text = songArtist
                artworkImage.image = UIImage(data: songArtwork)
                titleLabel.text = songTitle
                backgroundImage.image = UIImage(data: songArtwork)
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
