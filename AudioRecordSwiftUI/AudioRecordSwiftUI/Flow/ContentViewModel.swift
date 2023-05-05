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
    @Published var alertModel: AlertModel? {
        didSet {
            needShowAllert = alertModel != nil
        }
    }
    @Published var needShowAllert = false
    
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
            if !successfullyRemoved {
                self?.alertModel = .init(title: "Что-то пошло не так", message: "Файл не может быть удалён")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func commonInit() {
        audioRecorderService.successFinishRecordStateHandler = { [weak self] canPlay in
            self?.state = .playing
            if !canPlay {
                self?.alertModel = .init(title: "Что-то пошло не так", message: "Невозможно прослушать запись")
            } else {
                self?.recordURL = self?.fileService.fetchRecord()
            }
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
        audioRecorderService.startRecord(with: fileService.startRecordDirectoryURL()) { [weak self] canRecord in
            self?.state = canRecord ? .stopped : .recording
            if !canRecord {
                self?.alertModel = .init(title: "Что-то пошло не так", message: "Запись не может быть начата")
            }
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
