//
//  Buttons.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 24/11/2022.
//

import SwiftUI

struct PrimaryButton: View {
    var title: String
    
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.orange)
            .cornerRadius(15)
    }
}

private struct SecondaryButton: View {
    var title: String
    
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.orange)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.white)
            .cornerRadius(15)
            .shadow(color: .orange, radius: 1)
            .padding(.vertical)
    }
}
