//
//  ContentViewAssemble.swift
//  AudioRecordSwiftUI
//
//  Created by Dmitry Kushner on 02.05.2023.
//

import SwiftUI

struct ContentViewAssemble {
    func assembe() -> ContentView {
        let viewModel = ContentViewModel()
        return ContentView(viewModel: viewModel)
    }
}
