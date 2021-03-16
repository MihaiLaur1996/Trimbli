//
//  WaveformView.swift
//  Trimbli
//
//  Created by Mihai Laurentiu Mocanu on 28/10/2020.
//

import UIKit

class WaveformView: UIView {
    var phase: CGFloat = 0
    @IBInspectable var amplitude: CGFloat = 1
    @IBInspectable var numberOfWaves:Int = 2
    @IBInspectable var waveColor: UIColor = .white
    @IBInspectable var primaryWaveLineWidth: CGFloat = 20
    @IBInspectable var secondaryWaveLineWidth: CGFloat = 18
    @IBInspectable var idleAmplitude: CGFloat = 0.01
    @IBInspectable var frequency: CGFloat = 1.5
    @IBInspectable var density: CGFloat = 5
    @IBInspectable var phaseShift: CGFloat = -0.15
    
    func updateWithLevel(_ level: CGFloat) {
        phase += phaseShift
        amplitude = fmax(level, idleAmplitude)
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.clear(bounds)
            self.backgroundColor?.set()
            context.fill(rect)
            
            for i in 0...self.numberOfWaves {
                let strokeLineWidth = i == 0 ? primaryWaveLineWidth : secondaryWaveLineWidth
                context.setLineWidth(strokeLineWidth)
                
                let halfHeight = bounds.height / 2
                let width = bounds.width
                let mid = width / 2
                
                let maxAmplitude = CGFloat((CGFloat(numberOfWaves) + bounds.width) / 15)
                let progress: CGFloat = CGFloat(i)
                let normedAmplitude = (1.5 * progress - CGFloat(2 / numberOfWaves)) * amplitude
                
                switch i {
                case 0: waveColor = #colorLiteral(red: 0.2156862745, green: 0.5921568627, blue: 0.6431372549, alpha: 1)
                case 1: waveColor = #colorLiteral(red: 0.1764705882, green: 0.7375224626, blue: 0.5294117647, alpha: 1)
                case 2: waveColor = #colorLiteral(red: 0.1568627451, green: 0.6705882353, blue: 0.7254901961, alpha: 1)
                default: AlertHandler.shared.showErrorMessage("There was a problem at soundwaves settings.")
                }
                
                let multiplier = min(1, (progress / 3 * 2) + (1 / 3))
                waveColor.withAlphaComponent(multiplier * waveColor.cgColor.alpha).set()
                for x in stride(from: 0, to: width + density, by: density) {
                    let scaling = 1 - pow(1 / mid * (x - mid), 2)
                    let y = scaling * maxAmplitude * normedAmplitude * CGFloat(sinf(Float(2 * .pi * x / width * frequency + phase))) + halfHeight
                    
                    if x == 0 {
                        context.move(to: CGPoint(x: x, y: y))
                    } else {
                        context.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                context.strokePath()
            }
        }
    }
}
