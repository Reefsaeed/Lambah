//
//  OnboardingPage2.swift
//  CustomObjectDetector
//
//  Created by Reef Saeed on 15/03/2025.
//
import SwiftUI

struct OnboardingPage2: View {
    var getStartedAction: () -> Void
    
    var body: some View {
        ZStack {
            // Use direct color if backC might be missing
            Color.backC.ignoresSafeArea()
            
            // Top rounded rectangle
            RoundedRectangle(cornerRadius: 200)
                .offset(y: -210)
                .fill(Color.primyC) // Use direct color instead of primyC
                .overlay(
                    RoundedRectangle(cornerRadius: 200)
                        .stroke(Color.strkC, lineWidth: 5) // Use direct color instead of strkC
                        .offset(y: -210)
                )
                .ignoresSafeArea()
            
            // Placeholder if image is missing
            if let _ = UIImage(named: "ph2") {
                Image("ph2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 210, height: 210)
            } else {
                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 210, height: 210)
                    .foregroundColor(.white)
            }
            
            Text("You will see a description of the sign")
                .fontWeight(.bold)
                .offset(y: -187)
                .multilineTextAlignment(.center)
                .lineLimit(10)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            Button(action: {
                getStartedAction()
            }) {
                Text("Start")
                    .foregroundColor(.white)
                    .padding(.horizontal, 80)
                    .padding(.vertical, 15)
                    .background(Color.yellow1) // Use system yellow if color asset is missing
                    .cornerRadius(18)
                    .bold()
            }
            .offset(y: 314)
        }
    }
}
