//
//  LandingView.swift
//  HealthApp
//
//  Created by Didem Akgün on 31.12.2024.
//

import SwiftUI

struct LandingView: View {
    @State private var navigateToQuiz = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Renkli arka plan (Gradient)
                LinearGradient(gradient: Gradient(colors: [.white, .red]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    Text("Kalp krizi olasılığını hesaplayan mobil uygulamaya hoş geldiniz")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.horizontal)

                    Text("Sağlığınız için bir adım önde")
                        .font(.headline)
                        .foregroundColor(.black)

                    // "Teste Başla" butonu
                    Button(action: {
                        navigateToQuiz = true
                    }) {
                        Text("Teste Başla")
                            .font(.headline)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            // iOS 16+ için yeni navigasyon
            .navigationDestination(isPresented: $navigateToQuiz) {
                OpenQuizView()
            }
        }
    }
}
