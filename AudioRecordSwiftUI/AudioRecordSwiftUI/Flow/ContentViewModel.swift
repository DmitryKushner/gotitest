//
//  ContentViewModel.swift
//  AudioRecordSwiftUI
//
//  Created by Dmitry Kushner on 02.05.2023.
//

import Combine
import SwiftUI
import AVFoundation

class ContentViewModel: NSObject, ObservableObject {
    // MARK: - Types
    
    enum RecordState {
        case withoutRecord
        case startRecord
        case haveRecord
        
        var buttonImageName: String {
            switch self {
            case .withoutRecord:
                return "withoutRecord"
            case .startRecord:
                return "startRecord"
            case .haveRecord:
                return "haveRecord"
            }
        }
    }
    
    // MARK: - Properties
    
    @Published private(set) var state: RecordState = .withoutRecord
    var audioPlayer: AVAudioPlayer!
    var audioRecorder: AVAudioRecorder!
    @Published var record: URL?
    
    // MARK: - Public Methods
    
    func startRecord() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath
            .appendingPathComponent("Test Dimas \(Date().toString(dateFormat: "dd-MM-YY 'at' HH:mm:ss")).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()

            state = .startRecord
        } catch {
            state = .withoutRecord
            print("Could not start recording")
        }
    }
    
    func finishRecord() {
        audioRecorder.stop()
        state = .haveRecord
    }
    
    func checkRecord() {
        fetchRecords() { [weak self] in
            guard let record = self?.record else {
                self?.state = .withoutRecord
                return
            }
            self?.state = .haveRecord
        }
    }
    
    func playRecord() {
        fetchRecords() { [weak self] in
            guard let record = self?.record else {
                self?.state = .withoutRecord
                return
            }
            
            let playbackSession = AVAudioSession.sharedInstance()
            
            do {
                try playbackSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            } catch {
                print("Playing over the device's speakers failed")
            }
            
            do {
                self?.audioPlayer = try AVAudioPlayer(contentsOf: record)
                self?.audioPlayer.delegate = self
                self?.audioPlayer.play()
            } catch {
                print("Playback failed.")
            }
        }
    }
    
    func deleteRecord() {
        guard let record = record else { return }
        do {
            try? FileManager.default.removeItem(at: record)
            state = .withoutRecord
        } catch {
            print("Error of deleting")
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchRecords(completion: @escaping () -> Void) {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            .filter {
                $0.absoluteString.contains("m4a")
            }

        record = directoryContents.first
        completion()
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension ContentViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        state = .haveRecord
    }
}
