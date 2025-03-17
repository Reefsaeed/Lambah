//
//  OnboardingPage1.swift
//  CustomObjectDetector
//
//  Created by Reef Saeed on 15/03/2025.
//

import Foundation
import SwiftUI

struct OnboardingPage1: View {
    // Action closures for buttons
    var skipAction: () -> Void
    var nextAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.backC.ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        skipAction() // Use the provided action
                    }) {
                        Text("Skip")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .bold()
                            .padding()
                    }
                }
                
                Spacer()
            }
            
            RoundedRectangle(cornerRadius: 200)
                .offset(y: 210)
                .fill(Color.primyC)
                .overlay(
                    RoundedRectangle(cornerRadius: 200)
                        .stroke(Color.strkC, lineWidth: 5)
                        .offset(y: 210)
                )
                .ignoresSafeArea()
            
            HStack {
                Image("ph")
                    .resizable()
                    .frame(width: 210, height: 210)
                    .ignoresSafeArea()
            }
            
            Text("Simply take a picture of the sign appears in the dashboard")
                .fontWeight(.bold)
                .offset(y: 187)
                .multilineTextAlignment(.center)
                .lineLimit(10)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            Button(action: {
                nextAction() // Use the provided action
            }) {
                Text("Next")
                    .foregroundColor(.white)
                    .padding(.horizontal, 80)
                    .padding(.vertical, 15)
                    .background(Color("yellow1"))
                    .cornerRadius(18)
                    .bold()
            }
            .offset(y: 314)
        }
    }
}
