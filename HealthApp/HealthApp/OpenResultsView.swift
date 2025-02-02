//
//  OpenResultsView.swift
//  HealthApp
//
//  Created by Didem Akgün on 19.12.2024.
//

import SwiftUI

struct OpenResultsView: View {
    var answers: [String]
    var resetQuizAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Tarama tamamlandı")
                .font(.title)
            
            ForEach(answers.indices, id: \.self) { index in
                Text("Cevap \(index + 1): \(answers[index])")
            }
            
            Button("Sıfırla") {
                resetQuizAction()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}
