//
//  AudioRecorderService.swift
//  AudioRecordSwiftUI
//
//  Created by Dmitry Kushner on 05.05.2023.
//

import AVFoundation

protocol AudioRecorderServiceProtocol: AnyObject {
    var successFinishRecordStateHandler: ((Bool) -> Void)? { get set }
    func startRecord(with recordURL: URL, completion: @escaping (Bool) -> Void)
    func finishRecord()
}

final class AudioRecorderService: NSObject, AudioRecorderServiceProtocol {
    // MARK: - Public Properties
    
    var successFinishRecordStateHandler: ((Bool) -> Void)?
    
    // MARK: - Private Properties
    
    private var audioRecorder: AVAudioRecorder? = nil
    private let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    // MARK: - Public Methods
    
    func startRecord(with recordURL: URL, completion: @escaping (Bool) -> Void) {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            completion(false)
            print("Failed to set up recording session")
        }
        
        audioRecorder = try? AVAudioRecorder(url: recordURL, settings: settings)
        audioRecorder?.delegate = self
        
        if audioRecorder?.prepareToRecord() == true {
            audioRecorder?.record()
            completion(true)
        } else {
            completion(false)
            print("Recorder cant record")
        }
    }
    
    func finishRecord() {
        audioRecorder?.stop()
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioRecorderService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        successFinishRecordStateHandler?(flag)
        print(flag ? "Record finished successfully" : "Record cant finish")
    }
}
