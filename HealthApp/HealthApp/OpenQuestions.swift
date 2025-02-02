//
//  OpenQuestion.swift
//  HealthApp
//
//  Created by Didem Akgün on 31.12.2024.
//

import SwiftUI

enum InputType: Equatable {
    case textField(placeholder: String) // Metin girişi
    case picker(options: [String])      // Genel Picker giriş
    case genderRadio                    // Özel cinsiyet (Kadın/Erkek) radio buton
}

struct OpenQuestion {
    var text: String
    var inputType: InputType
}
