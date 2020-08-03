//
//  File.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/16/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import Foundation
import AVFoundation

class Audio {
    var player: AVAudioPlayer?
    
    func playSound(file: String) {
        let url = Bundle.main.url(forResource: file, withExtension: "mp3")
        do {
            player = try AVAudioPlayer.init(contentsOf: url!)
            player?.play()
        } catch {
            print("Sound not found")
        }
    }
}
