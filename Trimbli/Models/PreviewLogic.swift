//
//  PreviewLogic.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 12.03.2021.
//

import UIKit
import AVFoundation

struct PreviewLogic {
    static func viewWillAppearCall(view: UIView, waveformView: WaveformView, playPauseButton: UIButton) {
        if MediaPlayer.shared.audioSourceConfiguration == .some(.localConfiguration) {
            waveformView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
            view.addSubview(waveformView)
            waveformView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                waveformView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                waveformView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                waveformView.topAnchor.constraint(equalTo: playPauseButton.bottomAnchor),
                waveformView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
    
    static func addPeriodicTimeObserver(_ progressSlider: UISlider, _ songTimeProgress: UILabel) {
        let interval = CMTimeMake(value: 1, timescale: 1)
        MediaPlayer.shared.timeObserverToken = MediaPlayer.shared.remotePlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { time in
            if MediaPlayer.shared.remotePlayer?.status == .some(.readyToPlay) {
                let progress = floor(CMTimeGetSeconds(time))
                PreviewLogic.setValues(progress, progressSlider, songTimeProgress)
            }
        })
    }
    
    private static func setValues(_ progress: Float64, _ progressSlider: UISlider, _ songTimeProgress: UILabel) {
        if progress.isNaN {
            return
        } else {
            if MediaPlayer.shared.remotePlayer?.timeControlStatus == .some(.playing) {
                if progressSlider.isHighlighted == false {
                    MediaPlayer.shared.progressValue = Float(MediaPlayer.shared.remotePlayer?.currentItem?.currentTime().seconds ?? 0.0)
                    progressSlider.setValue(MediaPlayer.shared.progressValue, animated: false)
                }
            } else if MediaPlayer.shared.progressValue != 0.0 {
                MediaPlayer.shared.progressValue = Float(MediaPlayer.shared.remotePlayer?.currentItem?.currentTime().seconds ?? 0.0)
                progressSlider.setValue(MediaPlayer.shared.progressValue, animated: false)
            }
            let minutes = (Int(progress) % 3600) / 60
            let seconds = (Int(progress) % 3600) % 60
            if seconds < 10 {
                MediaPlayer.shared.currentTime = "\(minutes):0\(seconds)"
            } else {
                MediaPlayer.shared.currentTime = "\(minutes):\(seconds)"
            }
            songTimeProgress.text = MediaPlayer.shared.currentTime
        }
    }
    
    static func playerReadyForPlayback(playPauseButton: UIButton) {
        if MediaPlayer.shared.remotePlayer?.status == .some(.readyToPlay) {
            if let playerItem = MediaPlayer.shared.playerItem {
                let totalDuration = CMTimeGetSeconds(playerItem.duration)
                PreviewLogic.notANumberCheck(totalDuration, playPauseButton)
            }
        }
    }
    
    private static func notANumberCheck(_ totalDuration: Float64, _ playPauseButton: UIButton) {
        if totalDuration.isNaN {
            playerReadyForPlayback(playPauseButton: playPauseButton)
        } else {
            if let duration = MediaPlayer.shared.playerItem?.duration.seconds {
                MediaPlayer.shared.duration = duration
            }
            MediaPlayerLogic.shared.getTotalDuration()
            playPauseButton.setImage(UIImage.pause, for: .normal)
        }
    }
    
    static func triggerLocalTimer(progressSlider: UISlider, songTimeProgress: UILabel) {
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
            MediaPlayerLogic.shared.notRepeatingAutoProgress()
            NotificationCenter.default.post(name: .updateUI, object: nil)
        } else if MediaPlayer.shared.localPlayer?.isPlaying == false && MediaPlayer.shared.repeatState == .repeating {
            MediaPlayerLogic.shared.progressThroughSongsLocal()
            NotificationCenter.default.post(name: .updateUI, object: nil)
        } else if MediaPlayer.shared.localPlayer?.isPlaying == false && MediaPlayer.shared.repeatState == .repeatingOnlyOne {
            MediaPlayer.shared.localPlayer?.play()
        }

        songTimeProgress.text = MediaPlayer.shared.currentTime
        NotificationCenter.default.post(name: .selectedLocal, object: nil)
    }
}
