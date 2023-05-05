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
        case recording
        case stopped
        case playing
    }
    
    // MARK: - Public Properties
    
    @Published var buttonImageName = ""
    @Published var deleteButtonHidden = true
    
    // MARK: - Private Properties
    
    private var state: RecordState = .recording {
        didSet {
            switch state {
            case .recording:
                buttonImageName = "withoutRecord"
                deleteButtonHidden = true
            case .stopped:
                buttonImageName = "startRecord"
                deleteButtonHidden = true
            case .playing:
                buttonImageName = "haveRecord"
                deleteButtonHidden = false
            }
        }
    }
    private var audioPlayerService: AudioPlayerServiceProtocol
    private var audioRecorderService: AudioRecorderServiceProtocol
    private var fileService: FileServiceProtocol
    private var recordURL: URL?
    
    // MARK: - Init
    
    override init() {
        audioPlayerService = AudioPlayerService()
        audioRecorderService = AudioRecorderService()
        fileService = FileService()
        super.init()
        commonInit()
    }
    
    // MARK: - Public Methods
    
    func handlePress() {
        switch state {
        case .recording:
            startRecord()
        case .stopped:
            finishRecord()
        case .playing:
            playRecord()
        }
    }
    
    func deleteRecord() {
        guard let recordURL = recordURL else { return }
        fileService.deleteRecord(with: recordURL) { [weak self] successfullyRemoved in
            self?.state = successfullyRemoved ? .recording : .stopped
        }
    }
    
    // MARK: - Private Methods
    
    private func commonInit() {
        audioRecorderService.successFinishRecordStateHandler = { [weak self] in
            self?.state = .playing
        }
        recordURL = fileService.fetchRecord()
        checkRecord()
    }
    
    private func checkRecord() {
        guard recordURL != nil else {
            state = .recording
            return
        }
        state = .playing
    }
    
    private func startRecord() {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath
            .appendingPathComponent("Test Dimas \(Date().toString(dateFormat: "dd-MM-YY 'at' HH:mm:ss")).m4a")
        
        audioRecorderService.startRecord(with: audioFilename) { [weak self] canRecord in
            self?.state = canRecord ? .stopped : .recording
        }
    }
    
    private func finishRecord() {
        audioRecorderService.finishRecord()
    }
    
    private func playRecord() {
        guard let recordURL = recordURL else {
            state = .recording
            return
        }
        
        audioPlayerService.playRecord(with: recordURL)
    }
}
