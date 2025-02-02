//
//  RadioButton.swift
//  HealthApp
//
//  Created by Didem Akgün on 31.12.2024.
//

import SwiftUI

struct RadioButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10)
                    }
                }
                Text(label)
                    .foregroundColor(.white)
            }
        }
    }
}
