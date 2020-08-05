//
//  VoiceTableViewCell.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/20/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceTableViewCell: UITableViewCell {
    
    var msgVM   = MessageViewModel() { didSet{
        let seconds     = stringFormate(time: Int(msgVM.voiceSec!)%60)
        let minuts      = stringFormate(time: Int(msgVM.voiceSec!)/60)
        timeLabel.text  = "\(minuts):\(seconds)"
        timestampLabel.text = msgVM.timestamp?.getMessageTime()
        seenImage.image   = msgVM.isSeen! ? UIImage(named: "Seen") : UIImage(named: "Unseen")
        }}
    
    
    var player  = AVAudioPlayer()
    var timer   = Timer()
    var max     = Double()
    var current = Double()
    var file    = Data()
    
    var isDownloaded = false
    var isPaused     = false
    
    
    @IBOutlet weak var VoiceStack: UIStackView!
    @IBOutlet weak var voiceView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var prograssBar: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var activityIndecator: UIActivityIndicatorView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var seenImage: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    private func initView() {
        voiceView.layer.cornerRadius = 12
        userImage.layer.cornerRadius = 25
        
        prograssBar.setProgress(0.0, animated: false)
        activityIndecator.isHidden = true
        contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        if player.isPlaying {
            pausePlayer()
        } else {
            if isDownloaded {
                isPaused ? startPlay() : playVoice(url: file)
            } else {
                startDownLoad()
                downloadFileFromURL()
            }
        }
    }
    
    private func downloadFileFromURL(){
        let url = URL(string: msgVM.voiceURL!)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let URL = data else { return }
            self.file = URL
            self.isDownloaded = true
            self.playVoice(url: URL)
        }
        task.resume()
    }
    
    private func playVoice(url: Data) {
        do {
            player = try AVAudioPlayer(data: url)
            player.prepareToPlay()
            player.volume = 1.0
            max = player.duration
            current = player.currentTime
            self.startPlay()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    // MARK:- Handled action button
    
    private func startDownLoad() {
        DispatchQueue.main.async {
            self.actionButton.isHidden = true
            self.activityIndecator.isHidden = false
            self.activityIndecator.startAnimating()
        }
    }
    
    private func startPlay() {
        DispatchQueue.main.async {
            self.timer = .scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleVoiceTime), userInfo: nil, repeats: true)
            self.timer.fire()
            self.player.play()
            self.isPaused = false
            self.activityIndecator.isHidden = true
            self.activityIndecator.stopAnimating()
            self.actionButton.isHidden = false
            self.actionButton.setImage(UIImage(named: "Pause"), for: .normal)
        }
    }
    
    private func pausePlayer() {
        DispatchQueue.main.async {
            self.actionButton.setImage(UIImage(named: "play"), for: .normal)
            self.timer.invalidate()
            self.player.pause()
            self.isPaused = true
        }
    }
    
    @objc private func handleVoiceTime() {
        current += 0.1
        prograssBar.progress = Float(current/max)
        let now = max - current
        let seconds = stringFormate(time: Int(now)%60)
        let minuts = stringFormate(time: Int(now)/60)
        timeLabel.text = "\(minuts):\(seconds)"
        if current >= max {
            timer.invalidate()
            let seconds = String(format: "%02d", Int(max) % 60)
            timeLabel.text = "\(Int(max/60)):\(seconds)"
            prograssBar.progress = 0.0
            current = 0.0
            player.pause()
            player.prepareToPlay()
            actionButton.setImage(UIImage(named: "play"), for: .normal)
        }
    }
    
    
    func dismiss() {
        timer.invalidate()
        player.stop()
        prograssBar.progress = 0.0
        actionButton.setImage(UIImage(named: "play"), for: .normal)
    }
    
    
    private func stringFormate(time: Int)-> String{
        return String(format: "%02d", Int(time) % 60)
    }
    
    
    
    func checkMessageType(senderID: String) {
        if senderID != currentUser.id {
            timeLabel.textAlignment = .right
            seenImage.isHidden = false
        } else {
            seenImage.isHidden = true
        }
    }
    
    
}
