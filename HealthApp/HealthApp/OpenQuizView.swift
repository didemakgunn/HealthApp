//
//  OpenQuizView.swift
//  HealthApp
//
//  Created by Didem Akgün on 31.12.2024.
//

import SwiftUI

struct OpenQuizView: View {
    @ObservedObject var viewModel = OpenQuizViewModel()

    @State private var userInput: String = ""
    @State private var selectedOption: String? = nil
    @State private var showValidationAlert = false

    var body: some View {
        ZStack {
            // Renkli arka plan (Gradient)
            LinearGradient(gradient: Gradient(colors: [.white, .red]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if viewModel.showResults {
                    // Sonuç Ekranı
                    let resultText = viewModel.predictHeartAttackRisk()
                    
                    Text("Tarama Tamamlandı")
                        .font(.title)
                        .foregroundColor(.black)

                    Text(resultText)
                        .font(.title2)
                        .foregroundColor(.red)

                    Button("Yeniden Başla") {
                        viewModel.resetQuiz()
                        userInput = ""
                        selectedOption = nil
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    
                } else {
                    // Mevcut soru
                    let currentQuestion = viewModel.openQuestions[viewModel.currentQuestionIndex]
                    
                    Text(currentQuestion.text)
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    switch currentQuestion.inputType {
                    case .textField(let placeholder):
                        TextField(placeholder, text: $userInput)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                        
                    case .picker(let options):
                        Picker("Seçiniz", selection: $selectedOption) {
                            Text("Seçiniz").tag(nil as String?)
                            ForEach(options, id: \.self) { opt in
                                Text(opt).tag(opt as String?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        
                    case .genderRadio:
                        HStack(spacing: 40) {
                            RadioButton(label: "Kadın",
                                        isSelected: viewModel.selectedGender == "Kadın") {
                                viewModel.selectedGender = "Kadın"
                            }
                            RadioButton(label: "Erkek",
                                        isSelected: viewModel.selectedGender == "Erkek") {
                                viewModel.selectedGender = "Erkek"
                            }
                        }
                    }

                    HStack {
                        // Geri Butonu
                        Button(action: {
                            userInput = ""
                            selectedOption = nil
                            viewModel.previousQuestion()
                        }) {
                            Text("Geri")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    viewModel.currentQuestionIndex == 0
                                    ? Color.gray : Color.white.opacity(0.2)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(viewModel.currentQuestionIndex == 0)
                        
                        // İleri Butonu
                        Button(action: {
                            if currentQuestion.inputType == .genderRadio {
                                guard let gender = viewModel.selectedGender else {
                                    showValidationAlert = true
                                    return
                                }
                                viewModel.addAnswer(gender)
                            }
                            else if case .textField = currentQuestion.inputType {
                                guard !userInput.isEmpty else {
                                    showValidationAlert = true
                                    return
                                }
                                viewModel.addAnswer(userInput)
                                userInput = ""
                            }
                            else if let selected = selectedOption {
                                viewModel.addAnswer(selected)
                                selectedOption = nil
                            }
                            else {
                                showValidationAlert = true
                            }
                        }) {
                            Text("İleri")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    ProgressView(value: Double(viewModel.currentQuestionIndex),
                                 total: Double(viewModel.openQuestions.count))
                        .padding()
                }
            }
            .padding()
            .alert(isPresented: $showValidationAlert) {
                Alert(title: Text("Uyarı"),
                      message: Text("Lütfen bu soruyu yanıtlayınız."),
                      dismissButton: .default(Text("Tamam")))
            }
        }
    }
}
