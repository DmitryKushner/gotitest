//
//  AudioPlayerService.swift
//  AudioRecordSwiftUI
//
//  Created by Dmitry Kushner on 05.05.2023.
//

import AVFoundation

protocol AudioPlayerServiceProtocol: AnyObject {
    func playRecord(with recordURL: URL)
}

final class AudioPlayerService: NSObject, AudioPlayerServiceProtocol {
    // MARK: - Private Properties
    
    private var audioPlayer: AVAudioPlayer? = nil
    
    // MARK: - Public Properties
    
    func playRecord(with recordURL: URL) {
        
        let playbackSession = AVAudioSession.sharedInstance()
        
        do {
            try playbackSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing over the device's speakers failed")
        }
        
        do {
            audioPlayer = try? AVAudioPlayer(contentsOf: recordURL)
            audioPlayer?.delegate = self
            if audioPlayer?.prepareToPlay() == true {
                audioPlayer?.play()
            } else {
                print("Player cant play")
            }
        }
    }
}

extension AudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("player finished successfully")
        }
    }
}
