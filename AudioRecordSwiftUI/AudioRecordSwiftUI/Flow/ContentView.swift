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
                    Button(action: { viewModel.handlePress() }) {
                        Image(viewModel.buttonImageName)
                            .renderingMode(
                                Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original)
                            )
                    }
                    .padding()
                    Button("Delete record") {
                        viewModel.deleteRecord()
                    }
                    .isHidden(viewModel.deleteButtonHidden)
                }
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewAssemble().assembe()
    }
}
