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
    @IBOutlet weak var songProgress: UISlider!
    @IBOutlet weak var timeProgress: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var songRepeat: UIButton!
    @IBOutlet weak var waveformView: WaveformView!
    
    private var colorTimer = Timer()
    private var progressTimer = Timer()
    private var colors: [CGFloat] = [0.0, 0.0, 0.0, CGFloat.random(in: 0.2...0.8), CGFloat.random(in: 0.2...0.8), CGFloat.random(in: 0.2...0.8)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(updateMeters))
        displayLink.add(to: .current, forMode: .common)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        colorTimer.invalidate()
        progressTimer.invalidate()
    }
    
    @IBAction func songProgressChanged(_ sender: UISlider) {
        colorTimer.invalidate()
        progressTimer.invalidate()
        MediaPlayer.shared.localPlayer?.currentTime = TimeInterval(sender.value)
        songProgress.setValue(sender.value, animated: true)
        getCurrentSeconds()
        updateUI()
    }
    
    @IBAction func backwardButton(_ sender: UIButton) {
        colorTimer.invalidate()
        colors[3] = CGFloat.random(in: 0.2...0.8)
        colors[4] = CGFloat.random(in: 0.2...0.8)
        colors[5] = CGFloat.random(in: 0.2...0.8)
        colorTimer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(changeColor), userInfo: nil, repeats: true)
        if MediaPlayer.shared.songIndex.row <= 0 {
            MediaPlayer.shared.songIndex.row = MediaPlayer.shared.downloadedSongs.count - 1
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[MediaPlayer.shared.songIndex.row].downloadedSongID
            MediaPlayer.shared.playLocal(songName: MediaPlayer.shared.chosenSong)
        } else {
            MediaPlayer.shared.songIndex.row -= 1
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[MediaPlayer.shared.songIndex.row].downloadedSongID
            MediaPlayer.shared.playLocal(songName: MediaPlayer.shared.chosenSong)
        }
        MediaPlayer.shared.repeatOne = false
        updateUI()
        NotificationCenter.default.post(name: .setSelected, object: nil)
    }
    
    @IBAction func playPauseButton(_ sender: UIButton) {
        if MediaPlayer.shared.localPlayer?.isPlaying == true {
            colorTimer.invalidate()
            progressTimer.invalidate()
            MediaPlayer.shared.localPlayer?.pause()
        } else {
            MediaPlayer.shared.localPlayer?.play()
        }
        
        updateUI()
    }
    
    @IBAction func forwardButton(_ sender: UIButton) {
        MediaPlayer.shared.repeatOne = false
        progressThroughSongs()
    }
    
    @IBAction func repeatSong(_ sender: UIButton) {
        if MediaPlayer.shared.repeatOne == false {
            MediaPlayer.shared.repeatOne = true
        } else {
            MediaPlayer.shared.repeatOne = false
        }
        updateUI()
    }
    
    func updateUI() {
        DispatchQueue.main.async { [self] in
            if MediaPlayer.shared.repeatOne == true {
                songRepeat.setImage(UIImage(named: "replay_button_one"), for: .normal)
            } else {
                songRepeat.setImage(UIImage(named: "replay_button"), for: .normal)
            }
            if MediaPlayer.shared.localPlayer?.isPlaying == true {
                playPauseButton.setImage(UIImage(named: "pause_button"), for: .normal)
            } else {
                playPauseButton.setImage(UIImage(named: "play_button"), for: .normal)
            }
            songProgress.setThumbImage(UIImage(systemName: "circle.fill", withConfiguration: UIImage.smallConfiguration), for: .normal)
            songProgress.setThumbImage(UIImage(systemName: "circle.fill", withConfiguration: UIImage.mediumConfiguration), for: .highlighted)
            colorTimer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(changeColor), userInfo: nil, repeats: true)
            progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
            getCurrentSeconds()
            songProgress.minimumValue = 0.0
            songProgress.maximumValue = Float(MediaPlayer.shared.localPlayer?.duration ?? 0.0)
            timeProgress.text = MediaPlayer.shared.currentTime
            songProgress.setValue(Float(MediaPlayer.shared.localPlayer?.currentTime ?? 0.0), animated: false)
            MediaPlayer.shared.getTotalDurationLocal()
            totalTime.text = MediaPlayer.shared.totalTime
            if let songArtist = MediaPlayer.shared.songArtist, let songArtwork = MediaPlayer.shared.songArtwork, let songTitle = MediaPlayer.shared.songTitle {
                artistLabel.text = songArtist
                artworkImage.image = UIImage(data: songArtwork)
                titleLabel.text = songTitle
            }
        }
    }
    
    func getCurrentSeconds() {
        let minutes = (Int(MediaPlayer.shared.localPlayer?.currentTime ?? 0.0) % 3600) / 60
        let seconds = (Int(MediaPlayer.shared.localPlayer?.currentTime ?? 0.0) % 3600) % 60
        if seconds < 10 {
            MediaPlayer.shared.currentTime = "\(minutes):0\(seconds)"
            timeProgress.text = MediaPlayer.shared.currentTime
        } else {
            MediaPlayer.shared.currentTime = "\(minutes):\(seconds)"
            timeProgress.text = MediaPlayer.shared.currentTime
        }
    }
    
    func progressThroughSongs() {
        colorTimer.invalidate()
        colors[3] = CGFloat.random(in: 0.2...0.8)
        colors[4] = CGFloat.random(in: 0.2...0.8)
        colors[5] = CGFloat.random(in: 0.2...0.8)
        colorTimer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(changeColor), userInfo: nil, repeats: true)
        if MediaPlayer.shared.songIndex.row >= MediaPlayer.shared.downloadedSongs.count - 1 {
            MediaPlayer.shared.songIndex.row = 0
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[MediaPlayer.shared.songIndex.row].downloadedSongID
            MediaPlayer.shared.playLocal(songName: MediaPlayer.shared.chosenSong)
        } else {
            MediaPlayer.shared.songIndex.row += 1
            MediaPlayer.shared.chosenSong = MediaPlayer.shared.downloadedSongs[MediaPlayer.shared.songIndex.row].downloadedSongID
            MediaPlayer.shared.playLocal(songName: MediaPlayer.shared.chosenSong)
        }
        updateUI()
        NotificationCenter.default.post(name: .setSelected, object: nil)
    }
    
    @objc func updateMeters() {
        if let averagePower = MediaPlayer.shared.localPlayer?.averagePower(forChannel: 0) {
            let normalizedValue: CGFloat = MediaPlayer.shared.normalizedPowerLevelFromDecibels(decibels: CGFloat(averagePower))
            MediaPlayer.shared.localPlayer?.updateMeters()
            waveformView.updateWithLevel(normalizedValue)
        }
    }
    
    @objc func updateAudioProgressView() {
        if MediaPlayer.shared.localPlayer?.isPlaying == true {
            if songProgress.isHighlighted == false {
                MediaPlayer.shared.progressValue = Float(MediaPlayer.shared.localPlayer?.currentTime ?? 0.0)
                songProgress.setValue(MediaPlayer.shared.progressValue, animated: false)
            }
            getCurrentSeconds()
        } else if MediaPlayer.shared.localPlayer?.isPlaying == false && MediaPlayer.shared.progressValue != 0.0 {
            MediaPlayer.shared.progressValue = Float(MediaPlayer.shared.localPlayer?.currentTime ?? 0.0)
            songProgress.setValue(MediaPlayer.shared.progressValue, animated: false)
        } else if MediaPlayer.shared.localPlayer?.isPlaying == false && MediaPlayer.shared.repeatOne == true {
            MediaPlayer.shared.progressValue = 0.0
            songProgress.setValue(MediaPlayer.shared.progressValue, animated: false)
            updateUI()
            MediaPlayer.shared.localPlayer?.play()
        } else if MediaPlayer.shared.localPlayer?.isPlaying == false {
            getCurrentSeconds()
            progressThroughSongs()
        }
    }
    
    @objc func changeColor() {
        if colors[0] < colors[3] {
            colors[0] += 0.0001
            if colors[1] < colors[4] {
                colors[1] += 0.0001
                if colors[2] < colors[5] {
                    colors[2] += 0.0001
                    DispatchQueue.main.async { [self] in
                        view.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                        waveformView.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                    }
                }
            }
        }

        if colors[0] < colors[3] {
            colors[0] += 0.0001
            if colors[2] < colors[5] {
                colors[2] += 0.0001
                if colors[1] < colors[4] {
                    colors[1] += 0.0001
                    DispatchQueue.main.async { [self] in
                        view.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                        waveformView.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                    }
                }
            }
        }

        if colors[1] < colors[4] {
            colors[1] += 0.0001
            if colors[2] < colors[5] {
                colors[2] += 0.0001
                if colors[0] < colors[3] {
                    colors[0] += 0.0001
                    DispatchQueue.main.async { [self] in
                        view.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                        waveformView.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                    }
                }
            }
        }

        if colors[1] < colors[4] {
            colors[1] += 0.0001
            if colors[0] < colors[3] {
                colors[0] += 0.0001
                if colors[2] < colors[5] {
                    colors[2] += 0.0001
                    DispatchQueue.main.async { [self] in
                        view.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                        waveformView.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                    }
                }
            }
        }

        if colors[2] < colors[5] {
            colors[2] += 0.0001
            if colors[0] < colors[3] {
                colors[0] += 0.0001
                if colors[1] < colors[4] {
                    colors[1] += 0.0001
                    DispatchQueue.main.async { [self] in
                        view.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                        waveformView.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                    }
                }
            }
        }

        if colors[2] < colors[5] {
            colors[2] += 0.0001
            if colors[1] < colors[4] {
                colors[1] += 0.0001
                if colors[0] < colors[3] {
                    colors[0] += 0.0001
                    DispatchQueue.main.async { [self] in
                        view.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                        waveformView.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                    }
                }
            }
        }

        if colors[0] > colors[3] {
            colors[0] -= 0.0001
            if colors[1] > colors[4] {
                colors[1] -= 0.0001
                if colors[2] > colors[5] {
                    colors[2] -= 0.0001
                    DispatchQueue.main.async { [self] in
                        view.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                        waveformView.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                    }
                }
            }
        }

        if colors[0] > colors[3] {
            colors[0] -= 0.0001
            if colors[2] > colors[5] {
                colors[2] -= 0.0001
                if colors[1] > colors[4] {
                    colors[1] -= 0.0001
                    DispatchQueue.main.async { [self] in
                        view.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                        waveformView.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                    }
                }
            }
        }

        if colors[1] > colors[4] {
            colors[1] -= 0.0001
            if colors[2] > colors[5] {
                colors[2] -= 0.0001
                if colors[0] > colors[3] {
                    colors[0] -= 0.0001
                    DispatchQueue.main.async { [self] in
                        view.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                        waveformView.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                    }
                }
            }
        }

        if colors[1] > colors[4] {
            colors[1] -= 0.0001
            if colors[0] > colors[3] {
                colors[0] -= 0.0001
                if colors[2] > colors[5] {
                    colors[2] -= 0.0001
                    DispatchQueue.main.async { [self] in
                        view.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                        waveformView.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                    }
                }
            }
        }

        if colors[2] > colors[5] {
            colors[2] -= 0.0001
            if colors[0] > colors[3] {
                colors[0] -= 0.0001
                if colors[1] > colors[4] {
                    colors[1] -= 0.0001
                    DispatchQueue.main.async { [self] in
                        view.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                        waveformView.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                    }
                }
            }
        }

        if colors[2] > colors[5] {
            colors[2] -= 0.0001
            if colors[1] > colors[4] {
                colors[1] -= 0.0001
                if colors[0] > colors[5] {
                    colors[0] -= 0.0001
                    DispatchQueue.main.async { [self] in
                        view.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                        waveformView.backgroundColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                    }
                }
            }
        }
    }
}
