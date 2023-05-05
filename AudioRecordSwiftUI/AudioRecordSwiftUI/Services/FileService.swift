//
//  FileService.swift
//  AudioRecordSwiftUI
//
//  Created by Dmitry Kushner on 05.05.2023.
//

import Foundation

protocol FileServiceProtocol: AnyObject {
    func startRecordDirectoryURL() -> URL
    func fetchRecord() -> URL?
    func deleteRecord(with recordURL: URL, completion: @escaping (Bool) -> Void)
}

final class FileService: FileServiceProtocol {
    // MARK: - Public Methods
    
    func startRecordDirectoryURL() -> URL {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath
            .appendingPathComponent("Test Dimas \(Date().toString(dateFormat: "dd-MM-YY 'at' HH:mm:ss")).m4a")
        return audioFilename
    }
    
    func fetchRecord() -> URL? {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try? FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            .filter {
                $0.absoluteString.contains("m4a")
            }

        return directoryContents?.first
    }
    
    func deleteRecord(with recordURL: URL, completion: @escaping (Bool) -> Void) {
        do {
            try FileManager.default.removeItem(at: recordURL)
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    // MARK: - Private Methods
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
