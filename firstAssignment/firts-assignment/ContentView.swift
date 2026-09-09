//
//  ContentView.swift
//  firts-assignment
//
//  Created by madiaslanov on 09.09.2026.
//

import SwiftUI

struct ContentView: View {
    private let lifeStory = buildLifeStory()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("My Life Story")
                    .font(.largeTitle)
                    .bold()

                Text(lifeStory)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
