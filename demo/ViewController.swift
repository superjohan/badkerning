//
//  ViewController.swift
//  demo
//
//  Created by Johan Halin on 12/03/2018.
//  Copyright © 2018 Dekadence. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController {
    let autostart = true
    let animationDuration = 0.4
    
    let audioPlayer: AVAudioPlayer
    let startButton: UIButton
    let qtFoolingBgView: UIView = UIView.init(frame: CGRect.zero)
    let contentView = UIView()

    let text = "“Like oratory, music, dance, calligraphy – like anything that lends its grace to language – typography is an art that can be deliberately misused. It is a craft by which the meanings of a text (or its absence of meaning) can be clarified, honored and shared, or knowingly disguised.”\n\nRobert Bringhurst, “The Elements of Typographic Style”"
    var labels = [UILabel]()
    var position = 0
    
    // MARK: - UIViewController
    
    init() {
        if let trackUrl = Bundle.main.url(forResource: "beaches2", withExtension: "m4a") {
            guard let audioPlayer = try? AVAudioPlayer(contentsOf: trackUrl) else {
                abort()
            }
            
            self.audioPlayer = audioPlayer
        } else {
            abort()
        }

        let startButtonText =
            "\"some demo\"\n" +
                "by dekadence\n" +
                "\n" +
                "programming and music by ricky martin\n" +
                "\n" +
                "presented at some party 2018\n" +
                "\n" +
        "tap anywhere to start"
        self.startButton = UIButton.init(type: UIButton.ButtonType.custom)
        self.startButton.setTitle(startButtonText, for: UIControl.State.normal)
        self.startButton.titleLabel?.numberOfLines = 0
        self.startButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.startButton.backgroundColor = UIColor.black
        
        super.init(nibName: nil, bundle: nil)
        
        self.startButton.addTarget(self, action: #selector(startButtonTouched), for: UIControl.Event.touchUpInside)
        
        self.view.backgroundColor = .black
        
        self.qtFoolingBgView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        // barely visible tiny view for fooling Quicktime player. completely black images are ignored by QT
        self.view.addSubview(self.qtFoolingBgView)
        
        self.contentView.isHidden = true
        self.contentView.backgroundColor = .white
        self.view.addSubview(self.contentView)
        
        if !self.autostart {
            self.view.addSubview(self.startButton)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.audioPlayer.prepareToPlay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.qtFoolingBgView.frame = CGRect(
            x: (self.view.bounds.size.width / 2) - 1,
            y: (self.view.bounds.size.height / 2) - 1,
            width: 2,
            height: 2
        )

        self.startButton.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        
        self.contentView.frame = self.startButton.frame
        
        createLabels()
    }
    
    private func createLabels() {
        let textBoxWidth: CGFloat = 510
        let left = (self.contentView.bounds.size.width / 2.0) - (textBoxWidth / 2.0)
        let right = left + textBoxWidth
        let font = UIFont(name: "Palatino", size: 20)
        
        var previousFrame: CGRect? = nil
        
        for i in self.text.indices {
            let char = self.text[i]
        
            let label = UILabel(frame: .zero)
            label.text = "\(char)"
            label.font = font
            label.sizeToFit()

            if char != " " && char != "\n" {
                self.contentView.addSubview(label)
                self.labels.append(label)
            }

            if var previousFrame = previousFrame {
                if char == "\n" {
                    previousFrame.origin = CGPoint(x: left, y: previousFrame.origin.y + (previousFrame.size.height * (2.0 / 3.0)))
                }

                func setFrame(previousFrame: CGRect) -> CGRect {
                    label.frame.origin = CGPoint(x: previousFrame.origin.x + previousFrame.size.width, y: previousFrame.origin.y)
                    return label.frame
                }
                
                if char == " " {
                    var nextIndex = self.text.index(after: i)
                    var nextCharacter = self.text[nextIndex]
                    var prevFrame = previousFrame
                    label.text = "\(nextCharacter)"
                    prevFrame = setFrame(previousFrame: prevFrame)
                    
                    while nextCharacter != " " && nextCharacter != "\n" {
                        nextIndex = self.text.index(after: nextIndex)
                        if nextIndex == self.text.indices.endIndex {
                            break
                        }
                        
                        nextCharacter = self.text[nextIndex]
                        label.text = "\(nextCharacter)"
                        
                        prevFrame = setFrame(previousFrame: prevFrame)
                    }
                    
                    if label.frame.origin.x > right {
                        label.frame.origin = CGPoint(x: left, y: previousFrame.origin.y + previousFrame.size.height + 4)
                    } else {
                        previousFrame = setFrame(previousFrame: previousFrame)
                    }
                } else {
                    previousFrame = setFrame(previousFrame: previousFrame)
                }
            } else {
                label.frame.origin = CGPoint(x: left, y: 0)
            }
            
            previousFrame = label.frame
        }
        
        guard let lastLabel = self.labels.last else { return }
        
        let boxHeight = lastLabel.frame.origin.y + lastLabel.bounds.size.height
        let top = (self.contentView.bounds.size.height / 2.0) - (boxHeight / 2.0)
        
        for label in self.labels {
            label.frame.origin.y += top
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.autostart {
            start()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.audioPlayer.stop()
    }
    
    // MARK: - Private
    
    @objc
    fileprivate func startButtonTouched(button: UIButton) {
        self.startButton.isUserInteractionEnabled = false
        
        // long fadeout to ensure that the home indicator is gone
        UIView.animate(withDuration: 4, animations: {
            self.startButton.alpha = 0
        }, completion: { _ in
            self.start()
        })
    }
    
    fileprivate func start() {
        self.audioPlayer.play()
        
        self.view.backgroundColor = .white
        self.contentView.isHidden = false
        
        scheduleEvents()
    }
    
    private func scheduleEvents() {
        let timestamps = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20.625, 20.75, 21, 21.375, 22, 22.75, 23, 23.375, 24, 24.625, 25, 25.375, 26, 27, 27.375, 28, 29, 30, 30.625, 30.75, 31, 31.375, 32, 32.75, 33, 33.375, 34, 34.625, 35, 35.375, 36, 37, 37.375, 38, 38.625, 38.75, 39, 39.375, 40, 41, 42, 43, 44, 44.625, 44.75, 45, 45.375, 46, 46.75, 47, 47.375, 48, 48.625, 49, 49.375, 50, 51, 51.375, 52, 52.625, 52.75, 53, 53.375, 54, 54.75, 55, 55.375, 56, 56.625, 57, 57.375, 58, 59]
        
        for timestamp in timestamps {
            perform(#selector(event), with: nil, afterDelay: timestamp)
        }
    }
    
    @objc private func event() {
        shake(long: self.position < 16)
        
        if self.position < 16 {
            randomize()
        }
        
        self.position += 1
    }
    
    private func shake(long: Bool) {
        let offset: CGFloat = 20
        let x = -offset + CGFloat.random(in: 0...(offset * 2))
        let y = -offset + CGFloat.random(in: 0...(offset * 2))
        
        self.contentView.center = CGPoint(x: self.view.center.x + x, y: self.view.center.y + y)
        
        UIView.animate(withDuration: long ? 0.2 : 0.1, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.2, options: [.curveEaseOut], animations: {
            self.contentView.center = self.view.center
        }, completion: nil)
    }
    
    private func randomize() {
        let count = (self.position + 1) * 3

        for _ in 0..<count {
            let label = self.labels.randomElement()!
            label.layer.removeAllAnimations()

            animateCharacter(label)
        }
    }
    
    private func square() {
        let maxLength = self.view.bounds.size.height - 40
        let length = CGFloat.random(in: 50...maxLength)
        let shuffledLabels = self.labels.shuffled()
        let charactersPerSide = shuffledLabels.count / 4
        
        for i in 0...3 {
            let startIndex = i * charactersPerSide
            let down = i % 2 == 0
            let startPosition: CGPoint

            switch i {
            case 0: startPosition = CGPoint(x: self.view.center.x - (length / 2.0), y: self.view.center.y - (length / 2.0))
            case 1: startPosition = CGPoint(x: self.view.center.x - (length / 2.0), y: self.view.center.y - (length / 2.0))
            case 2: startPosition = CGPoint(x: self.view.center.x + (length / 2.0), y: self.view.center.y - (length / 2.0))
            case 3: startPosition = CGPoint(x: self.view.center.x - (length / 2.0), y: self.view.center.y + (length / 2.0))
            default: abort()
            }
            
            let distance = length / CGFloat(charactersPerSide)
            
            for (index, label) in shuffledLabels[startIndex..<(startIndex + charactersPerSide)].enumerated() {
                label.layer.removeAllAnimations()
                
                UIView.animate(withDuration: self.animationDuration, delay: 0, options: [.curveEaseOut], animations: {
                    if down {
                        label.center = CGPoint(x: startPosition.x, y: startPosition.y + (CGFloat(index) * distance))
                    } else {
                        label.center = CGPoint(x: startPosition.x + (CGFloat(index) * distance), y: startPosition.y)
                    }
                }, completion: { _ in
                    self.animateCharacter(label, small: true)
                })
            }
        }
        
        let remainingCharacters = shuffledLabels[(charactersPerSide * 4)..<shuffledLabels.count]

        for label in remainingCharacters {
            animateCharacter(label)
        }
    }
    
    private func rectangle() {
        let maxWidth = self.view.bounds.size.width - 40
        let maxHeight = self.view.bounds.size.height - 40
        let width = CGFloat.random(in: 50...maxWidth)
        let height = CGFloat.random(in: 50...maxHeight)
        let shuffledLabels = self.labels.shuffled()
        let totalLength = (width * 2) + (height * 2)
        let charactersByWidth = Int((width / totalLength) * CGFloat(shuffledLabels.count))
        let charactersByHeight = Int((height / totalLength) * CGFloat(shuffledLabels.count))
        let slices = [
            shuffledLabels[0..<charactersByWidth],
            shuffledLabels[charactersByWidth..<(charactersByWidth * 2)],
            shuffledLabels[(charactersByWidth * 2)..<((charactersByWidth * 2) + charactersByHeight)],
            shuffledLabels[((charactersByWidth * 2) + charactersByHeight)..<((charactersByWidth * 2) + (charactersByHeight * 2))]
        ]
        let endIndex = (charactersByWidth * 2) + (charactersByHeight * 2)
        
        for i in 0...3 {
            let slice = slices[i]
            let down = i >= 2
            let startPosition: CGPoint
            
            switch i {
            case 0: startPosition = CGPoint(x: self.view.center.x - (width / 2.0), y: self.view.center.y - (height / 2.0))
            case 1: startPosition = CGPoint(x: self.view.center.x - (width / 2.0), y: self.view.center.y + (height / 2.0))
            case 2: startPosition = CGPoint(x: self.view.center.x + (width / 2.0), y: self.view.center.y - (height / 2.0))
            case 3: startPosition = CGPoint(x: self.view.center.x - (width / 2.0), y: self.view.center.y - (height / 2.0))
            default: abort()
            }
            
            let distance = down ? height / CGFloat(charactersByHeight) : width / CGFloat(charactersByWidth)
            
            for (index, label) in slice.enumerated() {
                label.layer.removeAllAnimations()
                
                UIView.animate(withDuration: self.animationDuration, delay: 0, options: [.curveEaseOut], animations: {
                    if down {
                        label.center = CGPoint(x: startPosition.x, y: startPosition.y + (CGFloat(index) * distance))
                    } else {
                        label.center = CGPoint(x: startPosition.x + (CGFloat(index) * distance), y: startPosition.y)
                    }
                }, completion: { _ in
                    self.animateCharacter(label, small: true)
                })
            }
        }

        let remainingCharacters = shuffledLabels[endIndex..<shuffledLabels.count]
        
        for label in remainingCharacters {
            animateCharacter(label)
        }
    }
    
    private func animateCharacter(_ label: UIView, small: Bool = false) {
        let offset: CGFloat = small ? 5 : 20
        let x = -offset + CGFloat.random(in: 0...(offset * 2))
        let y = -offset + CGFloat.random(in: 0...(offset * 2))
        
        UIView.animate(withDuration: self.animationDuration, delay: 0, options: [.curveLinear], animations: {
            label.center = CGPoint(x: label.center.x + x, y: label.center.y + y)
        }, completion: { _ in
            UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseOut], animations: {
                label.center = CGPoint(x: label.center.x + x, y: label.center.y + y)
            }, completion: nil)
        })
    }
    
    private enum Shape {
        case square
        case rectangle
        case quad
        case equilateralTriangle
        case triangle
        case circle
    }
}
