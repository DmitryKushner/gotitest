//
//  ContentView.swift
//  AudioRecordSwiftUI
//
//  Created by Dmitry Kushner on 02.05.2023.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.top)
            VStack {
                Spacer()
                VStack {
                    Button(action: {
                        switch viewModel.state {
                        case .withoutRecord:
                            viewModel.startRecord()
                        case .startRecord:
                            viewModel.finishRecord()
                        case .haveRecord:
                            viewModel.playRecord()
                        }
                    }) {
                        Image(viewModel.state.buttonImageName)
                            .renderingMode(
                                Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original)
                            )
                    }
                    .padding()
                    Button("Delete record") {
                        viewModel.deleteRecord()
                    }
                    .isHidden(viewModel.state != .haveRecord)
                }
                Spacer()
            }
        }
        .onAppear {
            viewModel.checkRecord()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewAssemble().assembe()
    }
}
