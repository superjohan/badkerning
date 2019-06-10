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
    
    let audioPlayer: AVAudioPlayer
    let startButton: UIButton
    let qtFoolingBgView: UIView = UIView.init(frame: CGRect.zero)
    let contentView = UIView()

    let text = "“Like oratory, music, dance, calligraphy – like anything that lends its grace to language – typography is an art that can be deliberately misused. It is a craft by which the meanings of a text (or its absence of meaning) can be clarified, honored and shared, or knowingly disguised.”\n\nRobert Bringhurst, “The Elements of Typographic Style”"
    var labels = [UILabel]()
    
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
        
        self.contentView.isHidden = false
        
        scheduleEvents()
    }
    
    private func scheduleEvents() {
        let bpm = 120.0
        let bar = (120.0 / bpm)
        let tick = bar / 16.0

        let timestamps = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20.625, 20.75, 21, 21.375, 22, 22.75, 23, 23.375, 24, 24.625, 25, 25.375, 26, 27, 27.375, 28, 29, 30, 30.625, 30.75, 31, 31.375, 32, 32.75, 33, 33.375, 34, 34.625, 35, 35.375, 36, 37, 37.375, 38, 38.625, 38.75, 39, 39.375, 40, 41, 42, 43, 44, 44.625, 44.75, 45, 45.375, 46, 46.75, 47, 47.375, 48, 48.625, 49, 49.375, 50, 51, 51.375, 52, 52.625, 52.75, 53, 53.375, 54, 54.75, 55, 55.375, 56, 56.625, 57, 57.375, 58, 59]
        
        for timestamp in timestamps {
            perform(#selector(event), with: nil, afterDelay: timestamp)
        }
    }
    
    @objc private func event() {
    }
}
