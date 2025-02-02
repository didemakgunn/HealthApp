//
//  OpenQuizViewModel.swift
//  HealthApp
//
//  Created by Didem Akgün on 31.12.2024.
//

import SwiftUI
import CoreML

class OpenQuizViewModel: ObservableObject {
    // 13 sorumuz
    @Published var openQuestions: [OpenQuestion] = [
        // 1) age
        OpenQuestion(text: "Yaşınızı giriniz",
                     inputType: .textField(placeholder: "Ör: 45")),
        
        // 2) Cinsiyet (Radyo buton)
        OpenQuestion(text: "Cinsiyetiniz",
                     inputType: .genderRadio),
        
        // 3) Göğüs ağrısı tipi (cp)
        OpenQuestion(text: "Göğüs ağrısı tipini seçiniz",
                     inputType: .picker(options: ["Tip 0", "Tip 1", "Tip 2", "Tip 3"])),
        
        // 4) trestbps
        OpenQuestion(text: "İstirahat kan basıncınızı giriniz",
                     inputType: .textField(placeholder: "Ör: 120")),
        
        // 5) chol
        OpenQuestion(text: "Kolesterol seviyenizi giriniz",
                     inputType: .textField(placeholder: "Ör: 200")),
        
        // 6) fbs
        OpenQuestion(text: "Açlık kan şekeri durumunuzu seçiniz",
                     inputType: .picker(options: ["< 120 mg/dl", "≥ 120 mg/dl"])),
        
        // 7) restecg
        OpenQuestion(text: "EKG sonucunuzu seçiniz",
                     inputType: .picker(options: ["Normal", "ST-T anormallikleri", "Sol ventrikül hipertrofisi"])),
        
        // 8) thalach
        OpenQuestion(text: "Maksimum kalp atış hızınızı giriniz",
                     inputType: .textField(placeholder: "Ör: 150")),
        
        // 9) exang
        OpenQuestion(text: "Egzersizle anjina var mı?",
                     inputType: .picker(options: ["Yok", "Var"])),
        
        // 10) oldpeak
        OpenQuestion(text: "ST depresyonu değerini giriniz",
                     inputType: .textField(placeholder: "Ör: 1.5")),
        
        // 11) slope
        OpenQuestion(text: "ST eğimini seçiniz (slope)",
                     inputType: .picker(options: ["0 (UpSloping)", "1 (Flat)", "2 (DownSloping)"])),
        
        // 12) ca
        OpenQuestion(text: "Boyanmış damar (0-4) sayısını seçiniz",
                     inputType: .picker(options: ["0", "1", "2", "3", "4"])),
        
        // 13) thal
        OpenQuestion(text: "Thal değerini seçiniz",
                     inputType: .picker(options: ["0 (Normal)", "1 (Fixed Defect)", "2 (Reversable Defect)", "3 (Diğer)"]))
    ]
    
    @Published var currentQuestionIndex: Int = 0
    @Published var showResults: Bool = false
    @Published var answers: [String] = []
    
    // Radio Button cinsiyet seçimi
    @Published var selectedGender: String? = nil

    // Bir sonrakine geç
    func nextQuestion() {
        currentQuestionIndex += 1
        if currentQuestionIndex >= openQuestions.count {
            showResults = true
        }
    }
    
    // Bir önceki soruya dön
    func previousQuestion() {
        guard currentQuestionIndex > 0 else { return }
        currentQuestionIndex -= 1
    }
    
    // Model tahmini – TERS ÇEVİRME ile risk gösterimi
    func predictHeartAttackRisk() -> String {
        let mappedInputs = mapUserAnswersToModelInputs(answers: answers)
        if mappedInputs.count != 13 {
            return "Girdi eşleştirmesi hatası"
        }

        do {
            // init(configuration:) ile deprecated uyarısı çözülür
            let config = MLModelConfiguration()
            let model = try KalpKrizi(configuration: config)
            
            // Model tahmini
            let prediction = try model.prediction(
                age: Int64(mappedInputs[0]),
                sex: Int64(mappedInputs[1]),
                cp: Int64(mappedInputs[2]),
                trestbps: Int64(mappedInputs[3]),
                chol: Int64(mappedInputs[4]),
                fbs: Int64(mappedInputs[5]),
                restecg: Int64(mappedInputs[6]),
                thalach: Int64(mappedInputs[7]),
                exang: Int64(mappedInputs[8]),
                oldpeak: mappedInputs[9],
                slope: Int64(mappedInputs[10]),
                ca: Int64(mappedInputs[11]),
                thal: Int64(mappedInputs[12])
            )
            
            // Normalde targetProbability[1] = yüksek risk
            // Biz bunu TERSİNE çevirerek düşük risk olarak gösteriyoruz
            if let riskProbability = prediction.targetProbability[1] {
                // Örneğin model 0.98 döndürdüyse, biz "1 - 0.98 = 0.02" gösterelim
                let reversedProbability = 1.0 - riskProbability
                let percentage = reversedProbability * 100
                return String(format: "Kalp krizi geçirme olasılığı: %% %.1f", percentage)
            } else {
                return "Tahmin edilemedi"
            }
        } catch {
            print("Tahmin hatası: \(error)")
            return "Tahmin yapılamadı"
        }
    }

    func resetQuiz() {
        currentQuestionIndex = 0
        answers.removeAll()
        showResults = false
        selectedGender = nil
    }
    
    // Cevap ekleme
    func addAnswer(_ answer: String) {
        // Örnek yaş validasyonu
        if currentQuestionIndex == 0 {
            if let age = Int(answer) {
                // Basit aralık: 5-10 veya 70-80
                if !( (5...10).contains(age) || (70...80).contains(age) ) {
                    answers.append("0") // Uygun değilse 0
                } else {
                    answers.append(answer)
                }
            } else {
                answers.append("0")
            }
        } else {
            answers.append(answer)
        }
        
        nextQuestion()
    }

    // String cevapları modelin beklediği numeric dizisine dönüştürme
    private func mapUserAnswersToModelInputs(answers: [String]) -> [Double] {
        /*
         0) age
         1) sex (Kadın=0, Erkek=1)
         2) cp
         3) trestbps
         4) chol
         5) fbs (<120=0, >=120=1)
         6) restecg
         7) thalach
         8) exang
         9) oldpeak
         10) slope
         11) ca
         12) thal
         */
        
        var arr = [Double](repeating: 0.0, count: 13)
        
        // age
        arr[0] = Double(answers[0]) ?? 0.0
        
        // sex
        if answers[1].contains("Erkek") {
            arr[1] = 1
        } else {
            arr[1] = 0
        }
        
        // cp
        if answers[2].contains("Tip 1") { arr[2] = 1 }
        else if answers[2].contains("Tip 2") { arr[2] = 2 }
        else if answers[2].contains("Tip 3") { arr[2] = 3 }
        else { arr[2] = 0 }
        
        // trestbps
        arr[3] = Double(answers[3]) ?? 0.0
        
        // chol
        arr[4] = Double(answers[4]) ?? 0.0
        
        // fbs
        if answers[5].contains("≥") { arr[5] = 1 }
        else { arr[5] = 0 }
        
        // restecg
        if answers[6].contains("ST-T") { arr[6] = 1 }
        else if answers[6].contains("Sol vent") { arr[6] = 2 }
        else { arr[6] = 0 }
        
        // thalach
        arr[7] = Double(answers[7]) ?? 0.0
        
        // exang
        if answers[8].contains("Var") { arr[8] = 1 }
        else { arr[8] = 0 }
        
        // oldpeak
        arr[9] = Double(answers[9]) ?? 0.0
        
        // slope
        if answers[10].contains("1") { arr[10] = 1 }
        else if answers[10].contains("2") { arr[10] = 2 }
        else { arr[10] = 0 }
        
        // ca
        arr[11] = Double(answers[11]) ?? 0.0
        
        // thal
        if answers[12].contains("1") { arr[12] = 1 }
        else if answers[12].contains("2") { arr[12] = 2 }
        else if answers[12].contains("3") { arr[12] = 3 }
        else { arr[12] = 0 }

        return arr
    }
}
